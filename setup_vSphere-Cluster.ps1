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

# Generate VM / ESXi List
$vm_name_list = gen_vm_name_list $vm_num $hv_ip_4oct_start
$nest_hv_hostname_list = gen_nest_hv_hostname_list $vm_num $hv_ip_4oct_start $nest_hv_hostname_prefix
$hv_ip_vmk0_list = gen_hv_ip_vmk0_list $vm_num $hv_ip_4oct_start $hv_ip_prefix_vmk0
$vc_hv_name_list = $hv_ip_vmk0_list

task_message "Main-00" ("Disconnect from All vCeners")
disconnect_all_vc

task_message "Main-01_Start" ("Setup Base-vSphere")
Connect-VIServer -Server $base_vc_address `
    -User $base_vc_user -Password $base_vc_pass -Force |
    select Name,Version,Build,IsConnected | Format-List
./parts/step_1-1_clone-esxi-vms_for-vsan.ps1
./parts/step_1-2_config-esxi-guest_for-vsan.ps1

task_message "Main-01_End" ("Setup Base-vSphere")
disconnect_all_vc

task_message "Main-02_Start" ("Setup Nested-vSphere")
Connect-VIServer -Server $nest_vc_address `
    -User $nest_vc_user -Password $nest_vc_pass -Force |
    select Name,Version,Build,IsConnected | Format-List
./parts/step_2-1_create-vsphere-cluster.ps1
./parts/step_2-2_create-vmk-port_on-vss.ps1

task_message "Main-02_End" ("Setup Nested-vSphere")
disconnect_all_vc
