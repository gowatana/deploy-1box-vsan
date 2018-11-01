# Load Config file.
$config_file_name = $args[0]
ls $config_file_name
if($? -eq $false){"config file not found."; exit}

./setup-02-04_clone-vsan-vms.ps1 $config_file_name
./setup-02-05_config-vsan-vms.ps1 $config_file_name
./setup-03-01_create-vsan-cluster.ps1 $config_file_name
./setup-03-02_create-vsan-cluster_hybrid.ps1 $config_file_name