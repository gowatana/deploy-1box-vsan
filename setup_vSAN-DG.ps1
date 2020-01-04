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
$vm_name_list = gen_vm_name_list $vm_num $hv_ip_4oct_start $hv_ip_prefix_vmk0
$nest_hv_hostname_list = gen_nest_hv_hostname_list $vm_num $hv_ip_4oct_start $nest_hv_hostname_prefix
$hv_ip_vmk0_list = gen_hv_ip_vmk0_list $vm_num $hv_ip_4oct_start $hv_ip_prefix_vmk0
$vc_hv_name_list = $hv_ip_vmk0_list

# Adjast Setup Flag
if($create_vsan_cluster -eq $true){$create_vsphre_cluster = $true}
if($create_vsphre_cluster -eq $true){$create_esxi_vms = $true}

task_message "AddDG-00" "Disconnect from All vCeners"
disconnect_all_vc

for($i=2; $i -le $vsan_dg_count; $i++){
    task_message "AddDG-01_Start" "Add VMDK for vSAN Disk Group"
    connect_vc -vc_addr $base_vc_address -vc_user $base_vc_user -vc_pass $base_vc_pass
    ./parts/step_5-1_add-vsan-vmdk.ps1

    task_message "AddDG-01_End" "Add VMDK for vSAN Disk Group"
    disconnect_all_vc

    task_message "AddDG-02_Start" "Add vSAN Disk Group"
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
    ./parts/step_5-2_fix-disk-type.ps1
    ./parts/step_5-3_add-vsan-dg.ps1

    task_message "AddDG-02_End" "Add vSAN Disk Group"
    disconnect_all_vc
}
