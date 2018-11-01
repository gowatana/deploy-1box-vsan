# Load Config file.
$config_file_name = $args[0]
. $config_file_name
if($? -eq $false){"config file not found."; exit}

$cluster = Get-Cluster -Name $cluster_name

# Enable vSAN Traffic
$cluster | Get-VMHost | Get-VMHostNetworkAdapter -Name vmk0 | 
    Set-VMHostNetworkAdapter -VsanTrafficEnabled:$true -Confirm:$false |
    ft -AutoSize VMHost,DeviceName,Mac,IP,SubnetMask,VsanTrafficEnabled

# Add HDD Mark
$cluster | Get-VMHost | Sort-Object Name | %{
    $hv = $_
    $esxcli = $hv | Get-EsxCli -V2
    $vsan_capacity_dev | % {
        $dev_name = $_
        "ESXi SATP Setting: " + $hv.Name
        $config = $esxcli.storage.nmp.satp.rule.add.CreateArgs()
    
        $config.satp = "VMW_SATP_LOCAL"
        $config.device = $dev_name
        $config.option = "disable_ssd"
        $esxcli.storage.nmp.satp.rule.add.Invoke($config)
        
        $config = $esxcli.storage.core.claiming.reclaim.CreateArgs()
        $config.device = $dev_name
        $esxcli.storage.core.claiming.reclaim.Invoke($config)
    }
}

# Enable vSAN
$cluster | Set-Cluster -VsanEnabled:$true -Confirm:$false |
    select Name,VsanEnabled

# Create vSAN DG
Get-Cluster $cluster_name | Get-VMHost | 
    New-VsanDiskGroup -SsdCanonicalName $vsan_cache_dev -DataDiskCanonicalName $vsan_capacity_dev |
    ft -AutoSize VMHost,DiskGroupType,DiskFormatVersion

"End"