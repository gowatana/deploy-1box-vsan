task_message "02-01-00" "ESXi VM List"
$vm_check_table = $vm_name_list | select `
    @{N="ESXi_VM";E={$_}},
    @{N="VM_already_exists";E={Get-VM $_ | Out-Null; $?}}
$vm_check_table | ft -AutoSize

task_message "02-01-00a" "Create VM Folder"
if(-Not $esxi_vm_folder_name){$esxi_vm_folder_name = ("VM_VC-" + $nest_vc_address + "_" + $nest_cluster_name)}
Get-Datacenter $base_dc_name | Get-Folder -Type VM -Name "vm" |
    New-Folder -Name $esxi_vm_folder_name -ErrorAction:Ignore | Out-Null
$esxi_vm_folder = Get-Datacenter $base_dc_name | Get-Folder -Type VM -Name $esxi_vm_folder_name
if($esxi_vm_folder.Count -gt 1){
    "Duplicate VM folders $esxi_vm_folder_name"
    Break
}
$esxi_vm_folder | select Name

task_message "02-01-00b" "Create ResourcePool"
if($base_rp_name){
    Get-Datacenter $base_dc_name | Get-Cluster -Name $base_cluster_name | Get-ResourcePool -Name "Resources" |
        New-ResourcePool -Name $base_rp_name -ErrorAction:Ignore | Out-Null
    $base_rp = Get-Datacenter $base_dc_name | Get-Cluster -Name $base_cluster_name | Get-ResourcePool -Name "Resources" |
        Get-ResourcePool -Name $base_rp_name | select -First 1
    $base_rp | select Name
}else{
    "Skip"
}

# Clone Nested ESXi VMs
$vm_name_list | ForEach-Object {
    $vm_name = $_

    task_message "02-01-01a" ("Clone VM: " + $vm_name)
    if($linked_clone -ne $true){
        if($base_rp){
            $vm = New-VM -VM $template_vm_name -Name $vm_name -ResourcePool $base_rp -Location $esxi_vm_folder -Datastore $base_ds_name -StorageFormat Thin -ErrorAction:Stop
        }else{
            $vm = New-VM -VM $template_vm_name -Name $vm_name -VMHost (Get-VMHost $base_hv_name) -Location $esxi_vm_folder -Datastore $base_ds_name -StorageFormat Thin -ErrorAction:Stop
        }
    }else {
        "Skip"
    }

    task_message "02-01-01b" ("Clone VM LinkedClone: " + $vm_name)
    if($linked_clone){
        $snapshot = Get-VM -Name $template_vm_name | Get-Snapshot | Sort-Object Created -Descending | select -First 1
        if($base_rp){
            $vm = New-VM -VM $template_vm_name -LinkedClone -ReferenceSnapshot $snapshot -Name $vm_name -ResourcePool $base_rp -Location $esxi_vm_folder -Datastore $base_ds_name -StorageFormat Thin -ErrorAction:Stop
        }else{
            $vm = New-VM -VM $template_vm_name -LinkedClone -ReferenceSnapshot $snapshot -Name $vm_name -VMHost (Get-VMHost $base_hv_name) -Location $esxi_vm_folder -Datastore $base_ds_name -StorageFormat Thin -ErrorAction:Stop
        }
    }else{
        "Skip"
    }
    
    
    $vm | select Name,NumCpu,MemoryGB,Folder,VMHost,HardwareVersion,GuestId | Format-List

    task_message "02-01-02" ("Set vNIC#1: " + $vm_name)
    $base_pg = Get-VMHost $base_hv_name | Get-VirtualPortGroup -Name $base_pg_name
    $vnic_1 = if(Get-VirtualNetwork -Name $base_pg_name | where {$_.NetworkType -ne "Network"}){
        $vm | Get-NetworkAdapter -Name "* 1" | Set-NetworkAdapter -Portgroup $base_pg -Confirm:$false
    } else {
        $vm | Get-NetworkAdapter -Name "* 1" | Set-NetworkAdapter -NetworkName $base_pg_name -Confirm:$false
    }
    $vnic_1 | select Parent,Name,NetworkName | ft -AutoSize

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

    task_message "02-01-08" ("Add vNIC: " + $vm_name)
    if($multi_vmnic -And ($multi_vmnic -ge 2)){
        $base_pg = Get-VMHost $base_hv_name | Get-VirtualPortGroup -Name $base_pg_name
        $vnics = 2..$multi_vmnic | ForEach-Object {
            if(Get-VirtualNetwork -Name $base_pg_name | where {$_.NetworkType -ne "Network"}){
                $vm | New-NetworkAdapter -Portgroup $base_pg -StartConnected:$true -Confirm:$false
            } else {
                $vm | New-NetworkAdapter -NetworkName $base_pg_name -StartConnected:$true -Confirm:$false
            }
        }
        $vnics | select Parent,Name,NetworkName | ft -AutoSize
    }
    
    task_message "02-01-09" ("Start VM: " + $vm_name)
    $vm | Start-VM | ft -AutoSize Name,VMHost,PowerState
}

task_message "02-01-10" "waiting for VM startup."
$vm_poweron_check_wait_sec = 30
$vm_poweron_check_interval_sec = 5
("startup Wait: " + $vm_poweron_check_wait_sec + "seconds")
Start-Sleep $vm_poweron_check_wait_sec

task_message "02-01-11" "VM PowerOn Check"
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

task_message "02-01-12" "List ToolsStatus"
Get-VM $vm_name_list | select `
    Name,
    PowerState,
    @{N="ToolsStatus";E={$_.Guest.ExtensionData.ToolsStatus}} |
    Sort-Object Name | ft -AutoSize
