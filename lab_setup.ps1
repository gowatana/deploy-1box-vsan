$config_file = $args[0]
$operation_type = $args[1]
$skip_question_check = $args[2]

# Load vSAN-Lab config file.
ls $config_file | Out-Null
if($? -eq $false){"Lab config file not found."; exit}
. ./scripts/load_variables.ps1 $config_file

if($operation_type -eq "pretest"){
    ./scripts/check_base_setting.ps1
}elseif($operation_type -eq "create"){
    ./scripts/check_base_setting.ps1
    if($skip_question_check -ne "skip"){
        $start_check = Read-Host "Start Setup ? (Enter yes to continue.)"
        if($start_check -ne "yes"){exit}
    }
    ./scripts/setup_vSAN-Cluster.ps1
}elseif($operation_type -eq "delete"){
    ./scripts/destroy_nest_cluster.ps1
    ./scripts/destroy_base_cluster.ps1
    ./scripts/check_base_setting.ps1
}else{
    Write-Host ("arg1: pretest, create, delete")
    exit
}
