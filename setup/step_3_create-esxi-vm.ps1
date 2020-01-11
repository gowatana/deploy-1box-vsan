# Load Config file.
$config_file_name = $args[0]
. $config_file_name
if($? -eq $false){"config file not found."; exit}

# Create VM for Nested ESXi
$vm = New-VM -Name $vm_name -VMHost $base_hv_name `
    -GuestId $guest_id `
    -NumCpu $num_cpu -CoresPerSocket $num_cpu `
    -MemoryGB $memory_gb `
    -DiskGB $vmdk_gb -Datastore $base_ds_name -StorageFormat Thin `
    -Portgroup $base_pg_name

# Nested Hypervisor setting for ESXi VM
$vm = Get-VM -Name $vm_name
$vm_config_spec = New-Object "VMware.Vim.VirtualMachineConfigSpec"
$vm_config_spec.NestedHVEnabled = $true
$vm.ExtensionData.ReconfigVM($vm_config_spec)
