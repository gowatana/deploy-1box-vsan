# Load Config file.
$config_file_name = $args[0]
ls $config_file_name
if($? -eq $false){"config file not found."; exit}
. $config_file_name

Disconnect-VIServer * -Confirm:$false -Force -ErrorAction:SilentlyContinue
Connect-VIServer -Server $base_vc_address `
    -User $base_vc_user -Password $base_vc_pass -Force
./setup-02-04_clone-vsan-vms.ps1 $config_file_name
./setup-02-05_config-vsan-vms.ps1 $config_file_name
Disconnect-VIServer * -Confirm:$false

Connect-VIServer -Server $nest_vc_address `
    -User $nest_vc_user -Password $nest_vc_pass -Force
./setup-03-01_create-vsan-cluster.ps1 $config_file_name
./setup-03-01a_setup-vsan-disk_allflash.ps1 $config_file_name
./setup-03-02_setup-vsan-cluster.ps1 $config_file_name
Disconnect-VIServer * -Confirm:$false