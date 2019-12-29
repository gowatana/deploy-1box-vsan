# Load Config file.
$env_file_name = $args[0]
ls $env_file_name | Out-Null
if($? -eq $false){"env file not found."; exit}
. $env_file_name

$config_file_name = $args[1]
ls $config_file_name | Out-Null
if($? -eq $false){"config file not found."; exit}
. $config_file_name

# Load Functions
. ./parts/functions.ps1

task_message "Witness-1_Start" "Setup Witness-Host VA"
Connect-VIServer -Server $base_vc_address `
    -User $base_vc_user -Password $base_vc_pass -Force |
    select Name,Version,Build,IsConnected | Format-List
./Witness/parts/step-1_clone-vSAN-Witness-VA.ps1

task_message "Witness-1_End" "Disconnect from All vCeners"
disconnect_all_vc

task_message "Witness-2_Start" "Setup Witness-Host Guest"
Connect-VIServer -Server $base_vc_address `
    -User $base_vc_user -Password $base_vc_pass -Force |
    select Name,Version,Build,IsConnected | Format-List
./Witness/parts/step-2_config-vSAN-Witness-VA-Guest.ps1

task_message "Witness-2_End" "Disconnect from All vCeners"
disconnect_all_vc

task_message "Witness-3_Start" "Setup Witness-Host on vCenter"
Connect-VIServer -Server $nest_vc_address `
    -User $nest_vc_user -Password $nest_vc_pass -Force |
    select Name,Version,Build,IsConnected | Format-List
./Witness/parts/step-3_add-vSAN-Witness-Host-WTS.ps1

task_message "Witness-3_End" ("Disconnect from All vCeners")
disconnect_all_vc