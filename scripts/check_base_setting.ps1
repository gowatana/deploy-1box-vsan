# Load Functions
. ./parts/functions.ps1

function check_format($check_id, $check_name, $check_result) {
    $check_result_output = if($check_result -eq $true){"ok"}else{"NG"}
    $check = "" | select check_id, check_result, check_name
    $check.check_id     = $check_id
    $check.check_result = $check_result_output
    $check.check_name   = $check_name
    return $check
}

# ----------------------------------------
# Test Step-01
task_message "Step-01" "Disconnect from All vCeners"
disconnect_all_vc

task_message "Check-01-01" "`$vm_name_list"
$vm_name_list

task_message "Check-01-02" "`$nest_hv_hostname_list"
$nest_hv_hostname_list

task_message "Check-01-03" "`$hv_ip_vmk0_list"
$hv_ip_vmk0_list

task_message "Check-01-04" "`$vc_hv_name_list"
$vc_hv_name_list

# Initialize the check table
$check_table = @()

# ----------------------------------------
# Test Step-02
task_message "Step-02-Start" "Login to Base-vSphere"
connect_vc -vc_addr $base_vc_address -vc_user $base_vc_user -vc_pass $base_vc_pass

task_message "Check-02-01" "if exists `$template_vm_name: $template_vm_name"
Get-VM -Name $template_vm_name -ErrorAction:Ignore | Out-Null
$check_table += check_format "Check-02-01" "if exists `$template_vm_name: $template_vm_name" ($? -eq $true)

task_message "Check-02-02" "if exists `$base_dc_name: $base_dc_name"
Get-Datacenter -Name $base_dc_name -ErrorAction:Ignore | Out-Null
$check_table += check_format "Check-02-02" "if exists `$base_dc_name: $base_dc_name" ($? -eq $true)

task_message "Check-02-03" "if exists `$base_cluster_name: $base_cluster_name"
Get-Datacenter -Name $base_dc_name | Get-Cluster -Name $base_cluster_name -ErrorAction:Ignore | Out-Null
$check_table += check_format "Check-02-03" "if exists `$base_cluster_name: $base_cluster_name" ($? -eq $true)

task_message "Check-02-04" "if exists `$base_hv_name: $base_hv_name"
Get-VMHost -Name $base_hv_name -ErrorAction:Ignore | Out-Null
$check_table += check_format "Check-02-04" "if exists `$base_hv_name: $base_hv_name" ($? -eq $true)

task_message "Check-02-05" "if exists `$base_ds_name: $base_ds_name"
Get-VMHost -Name $base_hv_name | Get-Datastore -Name $base_ds_name -ErrorAction:Ignore | Out-Null
$check_table += check_format "Check-02-05" "if exists `$base_ds_name: $base_ds_name" ($? -eq $true)

$hv_count = 0
Get-Datacenter -Name $base_dc_name | Get-Cluster -Name $base_cluster_name | Get-VMHost | Sort-Object Name | ForEach-Object {
    $hv = $_
    $hv_name = $hv.Name
    $hv_count += 1
    task_message ("Check-02-06-" + $hv_count.ToString("00")) "if exists `$base_pg_name:$base_pg_name ESXi:$hv_name"
    $hv | Get-VirtualPortGroup -Name $base_pg_name -ErrorAction:Ignore | select Name,VLanId | Format-List
    $check_table += check_format ("Check-02-06-" + $hv_count.ToString("00")) "if exists `$base_pg_name:$base_pg_name ESXi:$hv_name" ($? -eq $true)
}

$vm_count = 0
$vm_name_list | ForEach-Object {
    $vm_name = $_
    $vm_count += 1
    task_message ("Check-02-07-" + $vm_count.ToString("00")) "if does NOT exist VM: $vm_name"
    Get-VM -Name $vm_name -ErrorAction:Ignore | select  Name,PowerState,Folder,ResourcePool
    $check_table += check_format ("Check-02-07-" + $vm_count.ToString("00")) "if does NOT exist VM: $vm_name" ($? -eq $false)
}

$vm_count = 0
$hv_ip_vmk0_list | ForEach-Object {
    $hv_ip_vmk0 = $_
    $vm_count += 1
    task_message ("Check-02-08-" + $vm_count.ToString("00")) "if does NOT reach vmk0-IP: $hv_ip_vmk0"
    $check_result = Test-Connection -Count 2 -Quiet $hv_ip_vmk0 -ErrorAction:Ignore
    $check_table += check_format ("Check-02-08-" + $vm_count.ToString("00")) "if does NOT reach vmk0-IP: $hv_ip_vmk0" ($check_result -eq $false)
}

$vm_count = 0
$nest_hv_hostname_list | ForEach-Object {
    $vm_count += 1
    $nest_hv_hostname = $_
    task_message ("Check-02-09-" + $vm_count.ToString("00")) "exists DNS Record: $nest_hv_hostname"
    $check_result = Resolve-DnsName $nest_hv_hostname -ErrorAction:Ignore
    $check_table += check_format ("Check-02-09-" + $vm_count.ToString("00")) "exists DNS Record: $nest_hv_hostname" ($? -eq $true)
}

task_message "Step-02-End" "Logout from Base-vSphere"
disconnect_all_vc

# ----------------------------------------
# Test Step-03
task_message "Step-03-Start" "Login Nested-vSphere"
connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass

task_message "Check-03-01" "if exists `$nest_dc_name: $nest_dc_name"
Get-Datacenter -Name $nest_dc_name -ErrorAction:Ignore
$check_table += check_format "Check-03-01" "if exists `$nest_dc_name: $nest_dc_name" ($? -eq $true)

task_message "Check-03-02" "if does NOT exist `$nest_cluster_name: $nest_cluster_name"
Get-Datacenter -Name $nest_dc_name | Get-Cluster $nest_cluster_name -ErrorAction:Ignore
$check_table += check_format "Check-03-02" "if does NOT exist `$nest_cluster_name: $nest_cluster_name" ($? -eq $false)

task_message "Check-03-03" "if exists `$base_ds_name: $vsan_ds_name"
Get-Datacenter -Name $nest_dc_name | Get-Datastore -Name $vsan_ds_name -ErrorAction:Ignore | Out-Null
$check_table += check_format "Check-03-03" "if does NOT exist `$vsan_ds_name: $vsan_ds_name" ($? -eq $false)

task_message "Step-03-End" "Logout from Nested-vSphere"
disconnect_all_vc

# ----------------------------------------
# Test Step-04
task_message "Step-04" "vSAN Witness VM Check"
if($create_witness_vm -eq $true){
    task_message "Step-04-Start" "Login to Base-vSphere"
    connect_vc -vc_addr $base_vc_address -vc_user $base_vc_user -vc_pass $base_vc_pass

    task_message "Check-04_01" "if exists `$base_witness_pg_name_1: $base_witness_pg_name_1"
    Get-VirtualPortGroup -Name $base_witness_pg_name_1 -ErrorAction:Ignore | select Name,VLanId
    $check_table += check_format "Check-04_01" "if exists `$base_witness_pg_name_1: $base_witness_pg_name_1" ($? -eq $true)
    
    task_message "Check-04_02" "if exists `$base_witness_pg_name_2: $base_witness_pg_name_2"
    Get-VirtualPortGroup -Name $base_witness_pg_name_2 -ErrorAction:Ignore | select Name,VLanId
    $check_table += check_format "Check-04_02" "if exists `$base_witness_pg_name_2: $base_witness_pg_name_2" ($? -eq $true)
    
    task_message "Check-04_03" "if exists `$vsan_witness_template_name: $vsan_witness_template_name"
    Get-VM $vsan_witness_template_name -ErrorAction:Ignore | Out-Null
    $check_table += check_format "Check-04_03" "if exists `$vsan_witness_template_name: $vsan_witness_template_name" ($? -eq $true)
    
    task_message "Check-04_04" "if does NOT exist `$vsan_witness_va_name: $vsan_witness_va_name"
    Get-VM $vsan_witness_va_name -ErrorAction:Ignore | Out-Null
    $check_table += check_format "Check-04_04" "if does NOT exist `$vsan_witness_va_name: $vsan_witness_va_name" ($? -eq $false)
    
    task_message "Step-04-End" "Logout from Base-vSphere"
    disconnect_all_vc
}else{
    "Skip"
}

# ----------------------------------------
# Test Step-05
task_message "Step-05" "vDS Check"
if($create_vds -eq $true){
    task_message "Step-05-Start" "Login to Nested-vSphere"
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass

    task_message "Check-05-01" "if does NOT exist `$vds_name: $vds_name"
    Get-Datacenter -Name $nest_dc_name | Get-VDSwitch -Name $vds_name -ErrorAction:Ignore | Out-Null
    $check_table += check_format "Check-05-01" "if does NOT exist `$vds_name: $vds_name" ($? -eq $false)
    
    task_message "Step-05-End" "Logout from Nested-vSphere"
    disconnect_all_vc
}

task_message "END" "Show Check table"
$check_table | ft -AutoSize
