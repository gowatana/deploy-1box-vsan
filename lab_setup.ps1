$config_file = $args[0]
$operation_type = $args[1]

# Load vSAN-Lab config file.
ls $config_file | Out-Null
if($? -eq $false){"vSAN-Lab config file not found."; exit}
. $config_file

# Load additional config files
if($create_vds -eq $true){
    Get-Item $vds_config -ErrorAction:Stop | fl FullName,LastWriteTime
    . $vds_config
}

if($create_witness_vm -eq $true){
    Get-Item $witness_config -ErrorAction:Stop | fl FullName,LastWriteTime
    . $witness_config
}

if($operation_type -eq "pretest"){
    ./scripts/check_base_setting.ps1
}elseif($operation_type -eq "create"){
    ./scripts/setup_vSAN-Cluster.ps1
}elseif($operation_type -eq "delete"){
    ./scripts/destroy_vSAN-Cluster.ps1
    ./scripts/check_base_setting.ps1
}else{
    Write-Host ("arg1: pretest, create, delete")
    exit
}
