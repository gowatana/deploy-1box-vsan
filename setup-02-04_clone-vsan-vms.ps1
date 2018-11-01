# Load Config file.
$config_file_name = $args[0]
. $config_file_name
if($? -eq $false){"config file not found."; exit}

"VM List:"
$vm_name_list

# Clone Nested ESXi VMs
$vm_name_list | % {
    $vm_name = $_
    $vm = New-VM -VM $template_vm_name -Name $vm_name -VMHost (Get-VMHost $base_hv_name) -StorageFormat Thin

    # Add VMDK
    $vm | New-HardDisk -SizeGB 20 -StorageFormat Thin
    $vm | New-HardDisk -SizeGB 50 -StorageFormat Thin
    $vm | New-HardDisk -SizeGB 50 -StorageFormat Thin
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
