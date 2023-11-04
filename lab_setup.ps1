$config_file = $args[0]
$operation_type = $args[1]

# Load vSAN-Lab config file.
ls $config_file | Out-Null
if($? -eq $false){"Lab config file not found."; exit}
. ./scripts/load_variables.ps1 $config_file

if($operation_type -eq "pretest"){
    ./scripts/check_base_setting.ps1
}elseif($operation_type -eq "create"){
    ./scripts/setup_vSAN-Cluster.ps1
}elseif($operation_type -eq "delete"){
    ./scripts/destroy_nest_cluster.ps1
    ./scripts/destroy_base_cluster.ps1
    ./scripts/check_base_setting.ps1
}else{
    Write-Host ("arg1: pretest, create, delete")
    exit
}
