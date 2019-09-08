# Load Config file.
$config_file_name = $args[0]
. $config_file_name
if($? -eq $false){"config file not found."; exit}

"VM List:"
$vm_name_list

# Clone Nested ESXi VMs
$vm_name_list | % {
    $vm_name = $_

    "Clone VM: $vm_name"
    $vm = New-VM -VM $template_vm_name -Name $vm_name -VMHost (Get-VMHost $base_hv_name) -StorageFormat Thin
    $vm | select Name,NumCpu,MemoryGB,Folder,VMHost, Version, GuestId | Format-List

    "Add VMDK (Cache device): " + $vm.Name
    $vm | New-HardDisk -SizeGB $vsan_cache_disk_size_gb -StorageFormat Thin |
        select Parent,Name,CapacityGB | ft -AutoSize
    
    "Add VMDK (Capacity device): " + $vm.Name
    for($i=1; $i -le $vsan_capacity_disk_count; $i++){
        $vm | New-HardDisk -SizeGB $vsan_capacity_disk_size_gb -StorageFormat Thin |
            select Parent,Name,CapacityGB | ft -AutoSize
    }

    "Start VM: $vm_name"
    $vm | Start-VM | ft -AutoSize Name,VMHost,PowerState
}

"waiting for VM startup."
sleep 30

# PowerOn Check
(Get-VM $vm_name_list | Sort-object Name) | % {
    $vm = $_
    $vm_name = $vm.Name
    for (){
        $vm = Get-VM $vm_name
        (Get-Date).DateTime + " " + $vm_name
        if($vm.Guest.ExtensionData.ToolsStatus -eq "toolsOk"){
            break
        }
        sleep 5
    }
}

Get-VM $vm_name_list | select `
    Name,
    PowerState,
    @{N="ToolsStatus";E={$_.Guest.ExtensionData.ToolsStatus}} |
    Sort-Object Name | ft -AutoSize
