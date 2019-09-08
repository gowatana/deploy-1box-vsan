# Load Config file.
$config_file_name = $args[0]
ls $config_file_name | Out-Null
if($? -eq $false){"config file not found."; exit}
. $config_file_name

# Disconnect from All vCeners
$global:DefaultVIServers | % {
    $vc = $_
    "Disconnect from VC: " + $vc.Name
    $vc | Disconnect-VIServer -Confirm:$false
}

Connect-VIServer -Server $base_vc_address `
    -User $base_vc_user -Password $base_vc_pass -Force |
    select Name,Version,Build,IsConnected | Format-List
./setup-02-04_clone-vsan-vms.ps1 $config_file_name
./setup-02-05_config-vsan-vms.ps1 $config_file_name
Disconnect-VIServer -Server $base_vc_address -Confirm:$false

Connect-VIServer -Server $nest_vc_address `
    -User $nest_vc_user -Password $nest_vc_pass -Force |
    select Name,Version,Build,IsConnected | Format-List
./setup-03-01_create-vsan-cluster.ps1 $config_file_name
./setup-03-01a_setup-vsan-disk_hybrid.ps1 $config_file_name
./setup-03-02_setup-vsan-cluster.ps1 $config_file_name
Disconnect-VIServer -Server $nest_vc_address -Confirm:$false