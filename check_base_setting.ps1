# Load vSAN-Lab Config file.
$lab_config_file_name = $args[0]
ls $lab_config_file_name | Out-Null
if($? -eq $false){"vSAN-Lab config file not found."; exit}
. $lab_config_file_name

# Load Functions
. ./parts/functions.ps1

# Generate VM / ESXi List
$vm_name_list = gen_vm_name_list $vm_num $hv_ip_4oct_start $hv_ip_prefix_vmk0
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
connect_vc -vc_addr $base_vc_address -vc_user $base_vc_user -vc_pass $base_vc_pass

# Base ESXi Setting
task_message "Check-02_01" ("`$template_vm_name: " + $template_vm_name)
Get-VM -Name $template_vm_name -ErrorAction:Ignore | Out-Null
if($? -eq $true){"OK"}else{"NG"}

task_message "Check-02_02" ("`$base_dc_name: " + $base_dc_name)
Get-Datacenter -Name $base_dc_name -ErrorAction:Ignore | Out-Null
if($? -eq $true){"OK"}else{"NG"}

task_message "Check-02_03" ("`$base_cluster_name: " + $base_cluster_name)
Get-Datacenter -Name $base_dc_name | Get-Cluster -Name $base_cluster_name -ErrorAction:Ignore | Out-Null
if($? -eq $true){"OK"}else{"NG"}

task_message "Check-02_04" ("`$base_hv_name: " + $base_hv_name)
Get-VMHost -Name $base_hv_name -ErrorAction:Ignore | Out-Null
if($? -eq $true){"OK"}else{"NG"}

task_message "Check-02_05" ("`$base_ds_name: " + $base_ds_name)
Get-VMHost -Name $base_hv_name | Get-Datastore -Name $base_ds_name -ErrorAction:Ignore | Out-Null
if($? -eq $true){"OK"}else{"NG"}

task_message "Check-02_06" ("`$base_pg_name: " + $base_pg_name)
Get-VirtualPortGroup -Name $base_pg_name -ErrorAction:Ignore | select Name,VLanId
if($? -eq $true){"OK"}else{"NG"}

task_message "Check-02_End" ("Logout Base-vSphere")
disconnect_all_vc

task_message "Check-03_Start" ("Login Nested-vSphere")
connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass

task_message "Check-03_01" ("`$nest_dc_name: " + $nest_dc_name)
Get-Datacenter -Name $nest_dc_name -ErrorAction:Ignore
if($? -eq $true){"OK"}else{"NG"}

task_message "Check-03_01" ("`$nest_cluster_name: " + $nest_cluster_name)
Get-Datacenter -Name $nest_dc_name | Get-Cluster $nest_cluster_name -ErrorAction:Ignore
if($? -eq $false){"OK"}else{"NG"}

task_message "Check-03_End" ("Logout Nested-vSphere")
disconnect_all_vc

if($create_witness_vm -eq $true){
    task_message "Check-04_Start" "Login Base-vSphere"
    connect_vc -vc_addr $base_vc_address -vc_user $base_vc_user -vc_pass $base_vc_pass

    task_message "Check-04_01" ("`$base_witness_pg_name_1: " + $base_witness_pg_name_1)
    Get-VirtualPortGroup -Name $base_witness_pg_name_1 -ErrorAction:Ignore | select Name,VLanId
    if($? -eq $true){"OK"}else{"NG"}

    task_message "Check-04_02" ("`$base_witness_pg_name_2: " + $base_witness_pg_name_2)
    Get-VirtualPortGroup -Name $base_witness_pg_name_2 -ErrorAction:Ignore | select Name,VLanId
    if($? -eq $true){"OK"}else{"NG"}
    
    task_message "Check-04_03" ("`$vsan_witness_template_name: " + $vsan_witness_template_name)
    Get-VM $vsan_witness_template_name -ErrorAction:Ignore | Out-Null
    if($? -eq $true){"OK"}else{"NG"}

    task_message "Check-04_04" ("`$vsan_witness_va_name: " + $vsan_witness_va_name)
    Get-VM $vsan_witness_va_name -ErrorAction:Ignore | Out-Null
    if($? -eq $false){"OK"}else{"NG"}

    task_message "Check-04_End" "Logout Base-vSphere"
    disconnect_all_vc
}
