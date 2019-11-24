task_message "02-04_00" ("VM Name List")
$vm_name_list

# Clone Nested ESXi VMs
$vm_name_list | % {
    $vm_name = $_

    task_message "02-04_01" ("Clone VM: " + $vm_name)
    $vm = New-VM -VM $template_vm_name -Name $vm_name -VMHost (Get-VMHost $base_hv_name) -Datastore $base_ds_name -StorageFormat Thin
    $vm | select Name,NumCpu,MemoryGB,Folder,VMHost, Version, GuestId | Format-List

    task_message "02-04_02" ("Add VMDK (Cache device): " + $vm_name)
    $vm | New-HardDisk -SizeGB $vsan_cache_disk_size_gb -StorageFormat Thin |
        select Parent,Name,CapacityGB | ft -AutoSize
    
    task_message "02-04_03" ("Add VMDK (Capacity device): " + $vm_name)
    for($i=1; $i -le $vsan_capacity_disk_count; $i++){
        $vm | New-HardDisk -SizeGB $vsan_capacity_disk_size_gb -StorageFormat Thin |
            select Parent,Name,CapacityGB | ft -AutoSize
    }

    task_message "02-04_04" ("Start VM: " + $vm_name)
    $vm | Start-VM | ft -AutoSize Name,VMHost,PowerState
}

task_message "02-04_05" ("waiting for VM startup. 30s")
$vm_poweron_check_wait_sec = 30
$vm_poweron_check_interval_sec = 5
Start-Sleep $vm_poweron_check_wait_sec

task_message "02-04_06" ("VM PowerOn Check")
(Get-VM $vm_name_list | Sort-object Name) | % {
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

task_message "02-04_07" ("List ToolsStatus")
Get-VM $vm_name_list | select `
    Name,
    PowerState,
    @{N="ToolsStatus";E={$_.Guest.ExtensionData.ToolsStatus}} |
    Sort-Object Name | ft -AutoSize
