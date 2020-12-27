$config_file = $args[0]
$operation_type = $args[1]

if($operation_type -eq "pretest"){
    ./scripts/check_base_setting.ps1 $config_file
}elseif($operation_type -eq "create"){
    ./scripts/setup_vSAN-Cluster.ps1 $config_file
}elseif($operation_type -eq "delete"){
    ./scripts/destroy_vSAN-Cluster.ps1 $config_file
    ./scripts/check_base_setting.ps1 $config_file
}else{
    Write-Host ("arg1: pretest, create, delete")
    exit
}
