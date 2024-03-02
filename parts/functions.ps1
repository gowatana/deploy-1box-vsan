# ----------------------------------------
# Format output

function task_message($task_id, $task_message) {
    ""
    "=" * 80
    "// Task_ID: " + $task_id.toString()
    "// Message: " + $task_message
}

# ----------------------------------------
# Connect / Disconnect vCenter

function disconnect_all_vc() {
    if($Global:DefaultVIServers){
        $Global:DefaultVIServers | ForEach-Object {
            $vc = $_
            ""
            "Disconnect from VC: " + $vc.Name
            $vc | Disconnect-VIServer -Confirm:$false
        }
    }
}

function connect_vc($vc_addr, $vc_user, $vc_pass) {
    $vc = Connect-VIServer -Server $vc_addr `
        -User $vc_user -Password $vc_pass -Force
    ""
    ($vc | select Name,Version,Build,IsConnected | Format-List | Out-String).Trim()
    if($vc.IsConnected -ne $True){
        "vCenter IsConnected: NOT True"
        exit 1
    }
}

# ----------------------------------------
# ESXi setting

function add_vss_pg {
    param (
        $hv_name,
        $vss_name,
        $vss_pg_name,
        $vlan_id
    )
    Get-VMHost -Name $hv_name | Get-VirtualSwitch -Name $vss_name |
        New-VirtualPortGroup -Name $vss_pg_name -VLanId $vlan_id
}

function add_vss_vmk_port {
    param (
        $hv_name,
        $vss_name,
        $vss_pg_name,
        $vmk_ip,
        $subnetmask
    )
    Get-VMHost -Name $hv_name |
        New-VMHostNetworkAdapter -VirtualSwitch $vss_name -PortGroup $vss_pg_name `
            -IP $vmk_ip -SubnetMask $subnetmask |
            select DeviceName,PortGroupName,Mac,IP,SubnetMask | ft -AutoSize
}

# ----------------------------------------
# Nested ESXi/vSAN Tips

function get_candidate_device {
    param (
        $esxi,
        [ValidateSet("Cache" , "Capacity")]$dev_type
    )

    $esxi_boot_device = "mpx.vmhba0:C0:T0:L0"
    $esxi_scsi_luns = $esxi | Get-VMHostDisk | select -ExpandProperty ScsiLun |
        where {$_.ScsiLun.CanonicalName -ne $esxi_boot_device} |
        where {$_.VsanStatus -eq "Eligible"} |
        select CapacityGB,CanonicalName |
        Sort-Object CapacityGB,CanonicalName
    
    switch ($dev_type) {
        "Cache" { $devices = $esxi_scsi_luns[0].CanonicalName }
        "Capacity" { $devices = $esxi_scsi_luns[1..($esxi_scsi_luns.Count - 1)].CanonicalName }
    }
    return $devices
}

function set_satp_rule {
    param (
        $esxi,
        $dev_list,
        $satp_rule_name = "VMW_SATP_LOCAL",
        $satp_rule_option = "disable_ssd"
    )

    $esxcli = $esxi | Get-EsxCli -V2
    $dev_list | % {
        $dev_name = $_
        "ESXi SATP Setting: " + `
            $esxi.Name + " " + $satp_rule_name + " " + $satp_rule_option
        $config = $esxcli.storage.nmp.satp.rule.add.CreateArgs()
    
        $config.satp = $satp_rule_name
        $config.device = $dev_name
        $config.option = $satp_rule_option
        $esxcli.storage.nmp.satp.rule.add.Invoke($config)
        
        $config = $esxcli.storage.core.claiming.reclaim.CreateArgs()
        $config.device = $dev_name
        $esxcli.storage.core.claiming.reclaim.Invoke($config)
    }
}

function mark_as_ssd {
    param (
        $esxi,
        $dev_list,
        $mark_device_ssd = $false
    )

    $dev_list | % {
        $dev_name = $_
        "SSD Setting: " + $esxi.Name + " " + $mark_device_ssd

        $host_storage_system = Get-View $esxi.ExtensionData.ConfigManager.StorageSystem
        $scsi_disk_uuid = $host_storage_system.StorageDeviceInfo.ScsiLun | where {$_.CanonicalName -eq $dev_name} | %{$_.Uuid}
        "SCSI Disk UUID: $scsi_disk_uuid"
        if($mark_device_ssd -eq $true){
            $host_storage_system.MarkAsSsd($scsi_disk_uuid) 
        }else{
            $host_storage_system.MarkAsNonSsd($scsi_disk_uuid) 
        }
    }
}

# ----------------------------------------
# vSAN ESA Tips
function add_nvme_controller {
    param (
        $vm
    )
    echo "DEBUG-NVMe: $vm"# DEBUG
    $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
    $spec.DeviceChange = New-Object VMware.Vim.VirtualDeviceConfigSpec[] (1)
    $spec.DeviceChange[0] = New-Object VMware.Vim.VirtualDeviceConfigSpec
    $spec.DeviceChange[0].Device = New-Object VMware.Vim.VirtualNVMEController
    $spec.DeviceChange[0].Device.DeviceInfo = New-Object VMware.Vim.Description
    $spec.DeviceChange[0].Device.DeviceInfo.Summary = 'NVMe Controller'
    $spec.DeviceChange[0].Device.DeviceInfo.Label = 'NVMe Controller'
    $spec.DeviceChange[0].Device.Key = -101
    $spec.DeviceChange[0].Device.BusNumber = 0
    $spec.DeviceChange[0].Operation = 'add'
    $spec.CpuFeatureMask = New-Object VMware.Vim.VirtualMachineCpuIdInfoSpec[] (0)
    $vm.ExtensionData.ReconfigVM($spec)
}

function add_nvme_disk {
    param (
        $vm,
        [int]$vmdk_size_gb,
        [int]$nvme_vmdk_count
    )
    $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
    $spec.DeviceChange = New-Object VMware.Vim.VirtualDeviceConfigSpec[] ($nvme_vmdk_count)
    for ($d = 0; $d -lt $nvme_vmdk_count; $d++) {
        $spec.DeviceChange[$d] = New-Object VMware.Vim.VirtualDeviceConfigSpec
        $spec.DeviceChange[$d].FileOperation = 'create'
        $spec.DeviceChange[$d].Device = New-Object VMware.Vim.VirtualDisk
        $spec.DeviceChange[$d].Device.Backing = New-Object VMware.Vim.VirtualDiskFlatVer2BackingInfo
        $spec.DeviceChange[$d].Device.Backing.FileName = ''
        $spec.DeviceChange[$d].Device.Backing.EagerlyScrub = $false
        $spec.DeviceChange[$d].Device.Backing.ThinProvisioned = $true
        $spec.DeviceChange[$d].Device.Backing.DiskMode = 'persistent'
        $spec.DeviceChange[$d].Device.ControllerKey = 31000
        $spec.DeviceChange[$d].Device.UnitNumber = $d
        $spec.DeviceChange[$d].Device.CapacityInKB = $vmdk_size_gb * 1024 * 1024
        $spec.DeviceChange[$d].Device.DeviceInfo = New-Object VMware.Vim.Description
        $spec.DeviceChange[$d].Device.DeviceInfo.Summary = 'New Hard Disk'
        $spec.DeviceChange[$d].Device.DeviceInfo.Label = 'New Hard Disk'
        $spec.DeviceChange[$d].Device.Key = -105 - $d
        $spec.DeviceChange[$d].Operation = 'add'
    }
    $spec.CpuFeatureMask = New-Object VMware.Vim.VirtualMachineCpuIdInfoSpec[] (0)
    $vm.ExtensionData.ReconfigVM($spec)
}

# ----------------------------------------
# vSAN Witness Host Tips

function set_vmk_witness_tag {
    param (
        $esxi,
        $vmk_port
    )

    $vmk_tag_name = "witness"
    "Add vmk $vmk_tag_name Tag: $esxi.Name to $vmk_port"  

    $esxcli = $esxi | Get-EsxCli -V2
    $config = $esxcli.vsan.network.ip.add.CreateArgs()
    $config.interfacename = $vmk_port
    $config.traffictype = $vmk_tag_name
    $esxcli.vsan.network.ip.add.Invoke($config)
}
