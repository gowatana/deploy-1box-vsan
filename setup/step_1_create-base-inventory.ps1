# Load Config file.
$config_file_name = $args[0]
. $config_file_name
if($? -eq $false){"config file not found."; exit}

# Create Base Datacenter
Get-Folder -Type Datacenter | New-Datacenter $base_dc_name -ErrorAction:Ignore

# Create Base Cluster
Get-Datacenter $base_dc_name | New-Cluster $base_cluster_name -ErrorAction:Ignore

# Add Base ESXi
Get-Datacenter $base_dc_name | Get-Cluster $base_cluster_name |
    Add-VMHost -Name $base_hv_name -User $base_hv_user -Password $base_hv_pass -Force
