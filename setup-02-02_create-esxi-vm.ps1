

$vm_name = "vm-esxi-template-01"
$hv_name = "192.168.1.20"

$guest_id = "vmkernel65Guest"
$num_cpu = 2
$memory_gb = 6
$ds_name = "datastore1"
$vmdk_gb = 16
$pg_name = "Nested-Trunk-Network"

$vm = New-VM -Name $vm_name -VMHost $hv_name `
    -GuestId $guest_id `
    -NumCpu $num_cpu -CoresPerSocket $num_cpu `
    -MemoryGB $memory_gb `
    -DiskGB $vmdk_gb -Datastore $ds_name -StorageFormat Thin `
    -NetworkName $pg_name

#$vm | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $pg_name -StartConnected:$true -Confirm:$false

$vm = Get-VM -Name $vm_name
$vm_config_spec = New-Object VMware.Vim.VirtualMachineConfigSpec
$vm_config_spec.NestedHVEnabled = $true
$vm.ExtensionData.ReconfigVM($vm_config_spec)

# $iso_path = "[datastore1] iso/ESXi-6.7.0-20181004001-standard.iso"
# $vm | New-CDDrive -IsoPath $iso_path -StartConnected:$true
