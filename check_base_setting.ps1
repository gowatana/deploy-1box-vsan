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

task_message "Main-01_00" ("Disconnect from All vCeners")
disconnect_all_vc

task_message "Check-01_01" ("`$vm_name_list:")
$vm_name_list

task_message "Check-01_02" ("`$nest_hv_hostname_list:")
$nest_hv_hostname_list

task_message "Check-01_03" ("`$hv_ip_vmk0_list:")
$hv_ip_vmk0_list

task_message "Check-01_04" ("`$vc_hv_name_list:")
$vc_hv_name_list

task_message "Check-02_Start" ("Login Base-vSphere")
Connect-VIServer -Server $base_vc_address `
    -User $base_vc_user -Password $base_vc_pass -Force |
    select Name,Version,Build,IsConnected | Format-List

# Base ESXi Setting
task_message "Check-02_01" ("`$template_vm_name:")
Get-VM -Name $template_vm_name | ft -AutoSize

task_message "Check-02_02" ("`$base_dc_name:")
Get-Datacenter -Name $base_dc_name | ft -AutoSize

task_message "Check-02_03" ("`$base_cluster_name:")
Get-Cluster -Name $base_cluster_name | ft -AutoSize

task_message "Check-02_04" ("`$base_hv_name:")
Get-VMHost -Name $base_hv_name | ft -AutoSize

task_message "Check-02_05" ("`base_ds_name:")
Get-Datastore -Name $base_ds_name | ft -AutoSize

task_message "Check-02_06" ("`base_pg_name:")
Get-VirtualPortGroup -Name $base_pg_name | ft -AutoSize # vDS NOT Support

task_message "Check-02_End" ("Logout Base-vSphere")
disconnect_all_vc

task_message "Check-03_Start" ("Login Nested-vSphere")
Connect-VIServer -Server $nest_vc_address `
    -User $nest_vc_user -Password $nest_vc_pass -Force |
    select Name,Version,Build,IsConnected | Format-List

task_message "Check-03_01" ("`$nest_dc_name:")
Get-Datacenter -Name $nest_dc_name | ft -AutoSize

task_message "Check-03_01" ("`$nest_cluster_name:")
Get-Cluster | where {$_.Name -eq $nest_cluster_name}
"If it is not displayed, it is OK."

task_message "Check-03_End" ("Logout Nested-vSphere")
disconnect_all_vc
