# Load Config file.
$config_file_name = $args[0]
. $config_file_name
if($? -eq $false){"config file not found."; exit}

$cluster = Get-Datacenter $base_dc_name | New-Cluster -Name $cluster_name

# Add ESXi to Cluster
$vc_hv_name_list | % {
    $hv_name = $_
    Add-VMHost -Name $hv_name -Location $cluster -User $hv_user -Password $hv_pass -Force
    Get-VMHost $hv_name | Remove-Datastore -Datastore "datastore*" -Confirm:$false -ErrorAction:Ignore
}

# Enable vSAN Traffic
$cluster | Get-VMHost | Get-VMHostNetworkAdapter -Name vmk0 | 
    Set-VMHostNetworkAdapter -VsanTrafficEnabled:$true -Confirm:$false |
    ft -AutoSize VMHost,DeviceName,Mac,IP,SubnetMask,VsanTrafficEnabled