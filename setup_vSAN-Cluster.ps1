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

task_message "Main-01" ("Disconnect from All vCeners")
disconnect_all_vc

task_message "Main-02_Start" ("Setup Base-vSphere")
Connect-VIServer -Server $base_vc_address `
    -User $base_vc_user -Password $base_vc_pass -Force |
    select Name,Version,Build,IsConnected | Format-List
./parts/setup-02-04_clone-vsan-vms.ps1
./parts/setup-02-05_config-vsan-vms.ps1

task_message "Main-02_End" ("Setup Base-vSphere")
disconnect_all_vc

task_message "Main-03_Start" ("Setup Nested-vSphere")
Connect-VIServer -Server $nest_vc_address `
    -User $nest_vc_user -Password $nest_vc_pass -Force |
    select Name,Version,Build,IsConnected | Format-List
./parts/setup-03-01_create-vsphere-cluster.ps1

task_message "Main-03_End" ("Setup Nested-vSphere")
disconnect_all_vc

task_message "Main-04_Start" ("Setup vSAN")
Connect-VIServer -Server $nest_vc_address `
    -User $nest_vc_user -Password $nest_vc_pass -Force |
    select Name,Version,Build,IsConnected | Format-List
./parts/setup-03-01a_setup-vsan-disk.ps1
./parts/setup-03-02_setup-vsan-cluster.ps1

task_message "Main-04_End" ("Setup vSAN")
disconnect_all_vc