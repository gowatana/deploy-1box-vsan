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

task_message "Destroy: Witness-Nest Start" "Setup Witness-Host on vCenter"
Connect-VIServer -Server $nest_vc_address `
    -User $nest_vc_user -Password $nest_vc_pass -Force |
    select Name,Version,Build,IsConnected | Format-List
$hv = Get-Datacenter -Name $witness_dc | Get-VMHost -Name $vsan_witness_host_vcname
$hv | Set-VMHost -State Disconnected -Confirm:$false
$hv | Remove-VMHost -Confirm:$false

task_message "Destroy: Witness-Nest End" ("Disconnect from All vCeners")
disconnect_all_vc

task_message "Destroy: Witness-Baes Start" "Setup Witness-Host VA"
Connect-VIServer -Server $base_vc_address `
    -User $base_vc_user -Password $base_vc_pass -Force |
    select Name,Version,Build,IsConnected | Format-List
$vm = Get-VM -Name $vsan_witness_va_name
$vm | Stop-VM -Confirm:$false
$vm| Remove-VM -DeletePermanently -Confirm:$false

task_message "Destroy: Witness-Base End" "Disconnect from All vCeners"
disconnect_all_vc
