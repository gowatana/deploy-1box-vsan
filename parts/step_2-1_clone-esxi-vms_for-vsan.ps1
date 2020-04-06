task_message "02-01-00" "ESXi VM List"
$vm_check_table = $vm_name_list | select `
    @{N="ESXi_VM";E={$_}},
    @{N="VM_already_exists";E={Get-VM $_ | Out-Null; $?}}
$vm_check_table | ft -AutoSize

# Clone Nested ESXi VMs
$vm_name_list | ForEach-Object {
    $vm_name = $_

    task_message "02-01-01" ("Clone VM: " + $vm_name)
    $vm = New-VM -VM $template_vm_name -Name $vm_name -VMHost (Get-VMHost $base_hv_name) -Datastore $base_ds_name -StorageFormat Thin -ErrorAction:Stop
    $vm | select Name,NumCpu,MemoryGB,Folder,VMHost,HardwareVersion,GuestId | Format-List

    task_message "02-01-02" ("Set vNIC#1: " + $vm_name)
    $vm | Get-NetworkAdapter -Name "* 1" | Set-NetworkAdapter -Portgroup (Get-VMHost $base_hv_name | Get-VirtualPortGroup -Name $base_pg_name) -Confirm:$false |
        select Parent,Name,NetworkName | ft -AutoSize

    task_message "02-01-03" ("Disconnect All vNICs: " + $vm_name)
    $vm | Get-NetworkAdapter | Set-NetworkAdapter -StartConnected:$false -Confirm:$false |
        Sort-Object Name | select Parent,Name,NetworkName,@{N="StartConnected";E={$_.ConnectionState.StartConnected}} | ft -AutoSize

    task_message "02-01-04" ("Add VMDK (Cache device): " + $vm_name)
    $vm | New-HardDisk -SizeGB $vsan_cache_disk_size_gb -StorageFormat Thin |
        select Parent,Name,CapacityGB | ft -AutoSize
    
    task_message "02-01-05" ("Add VMDK (Capacity device): " + $vm_name)
    for($i=1; $i -le $vsan_capacity_disk_count; $i++){
        $vm | New-HardDisk -SizeGB $vsan_capacity_disk_size_gb -StorageFormat Thin |
            select Parent,Name,CapacityGB | ft -AutoSize
    }

    task_message "02-01-06" ("Set ESXi Memory size: " + $vm_name)
    if($esxi_memory_gb){
        $vm | Set-VM -MemoryGB $esxi_memory_gb -Confirm:$false
    }else{
        "Skip"
    }

    task_message "02-01-07" ("Set Memory size for Multi-DG: " + $vm_name)
    $esxi_memory_gb_for_multi_dg = 10
    if($vsan_dg_count -And ($vsan_dg_count -ge 2)){
        if($esxi_memory_gb){
            if($esxi_memory_gb -lt $esxi_memory_gb_for_multi_dg){
                $esxi_memory_gb = $esxi_memory_gb_for_multi_dg
            }
        }else{
            $esxi_memory_gb = $esxi_memory_gb_for_multi_dg
        }
        $vm | Set-VM -MemoryGB $esxi_memory_gb -Confirm:$false
    }else{
        "Skip"
    }

    task_message "02-01-08" ("Start VM: " + $vm_name)
    $vm | Start-VM | ft -AutoSize Name,VMHost,PowerState
}

task_message "02-01-09" "waiting for VM startup."
$vm_poweron_check_wait_sec = 30
$vm_poweron_check_interval_sec = 5
("startup Wait: " + $vm_poweron_check_wait_sec + "seconds")
Start-Sleep $vm_poweron_check_wait_sec

task_message "02-01-10" "VM PowerOn Check"
(Get-VM $vm_name_list | Sort-object Name) | ForEach-Object {
    $vm = $_
    $vm_name = $vm.Name
    for (){
        $vm = Get-VM $vm_name
        (Get-Date).DateTime + " " + $vm_name
        if($vm.Guest.ExtensionData.ToolsStatus -eq "toolsOk"){
            Write-Host "toolsOk"
            break
        }
        Start-Sleep $vm_poweron_check_interval_sec
    }
}

task_message "02-01-11" "List ToolsStatus"
Get-VM $vm_name_list | select `
    Name,
    PowerState,
    @{N="ToolsStatus";E={$_.Guest.ExtensionData.ToolsStatus}} |
    Sort-Object Name | ft -AutoSize

task_message "02-01-12" "Create VM Folder"
if(-Not $esxi_vm_folder_name){$esxi_vm_folder_name = ("vms_" + $nest_cluster_name)}
Get-Datacenter $base_dc_name | Get-Folder -Type VM -Name "vm" |
    New-Folder -Name $esxi_vm_folder_name -ErrorAction:Ignore | select Name

task_message "02-01-13" ("Move VM to Folder: " + $esxi_vm_folder_name)
Get-VM $vm_name_list | Move-VM -InventoryLocation (Get-Folder -Type VM -Name $esxi_vm_folder_name) | Out-Null
Get-VM $vm_name_list | Sort-object Name | select Name,Folder
