# Load Config file.
$config_file_name = $args[0]
. $config_file_name
if($? -eq $false){"config file not found."; exit}

Get-Folder -Type Datacenter | New-Datacenter $base_dc_name
Get-Datacenter $base_dc_name | New-Cluster $base_cluster_name
Get-Cluster $base_cluster_name | Add-VMHost -Name $base_hv_name -User $base_hv_user -Password $base_hv_pass -Force
