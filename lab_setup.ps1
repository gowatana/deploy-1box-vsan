$config_file = $args[0]
$operation_type = $args[1]

# Load vSAN-Lab config file.
ls $config_file | Out-Null
if($? -eq $false){"Lab config file not found."; exit}
. $config_file

"Load Base-vCenter Configs"
Get-Item $base_vc_config -ErrorAction:Stop | fl FullName,LastWriteTime
. $base_vc_config
$base_vc_address = $vc_address
$base_vc_user = $vc_user
$base_vc_pass = $vc_pass

"Load Nest-vCenter Configs"
Get-Item $nest_vc_config -ErrorAction:Stop | fl FullName,LastWriteTime
. $nest_vc_config
$nest_vc_address = $vc_address
$nest_vc_user = $vc_user
$nest_vc_pass = $vc_pass

"Load Base-vSphere Config file:"
Get-Item $base_env_config -ErrorAction:Stop | fl FullName,LastWriteTime
. $base_env_config

"Load Nest-vSphere Config file:"
Get-Item $nest_env_config -ErrorAction:Stop | fl FullName,LastWriteTime
. $nest_env_config

"Load vDS-vSphere Config file:"
if($create_vds -eq $true){
    Get-Item $vds_config -ErrorAction:Stop | fl FullName,LastWriteTime
    . $vds_config
}else{
    "Skip"
}

"Load vSAN-Witness-VA Config file:"
if($create_witness_vm -eq $true){   
    Get-Item $witness_config -ErrorAction:Stop | fl FullName,LastWriteTime
    . $witness_config
}else{
    "Skip"
}

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
