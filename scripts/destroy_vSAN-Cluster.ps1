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

# fix VM Folder name
if(-Not $esxi_vm_folder_name){$esxi_vm_folder_name = ("VM_VC-" + $nest_vc_address + "_" + $nest_cluster_name)}

# Disconnect from All vCeners
disconnect_all_vc

task_message "Step-01" "Remove vSAN Cluster and ESXi"
connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
$cluster = Get-Datacenter $nest_dc_name | Get-Cluster $nest_cluster_name
if($? -eq $true){
    $cluster | Get-VMHost | Set-VMHost -State Disconnected -Confirm:$false
    $cluster | Get-VMHost | Remove-VMHost -Confirm:$false
    $cluster | Remove-Cluster -Confirm:$false
}
disconnect_all_vc

task_message "Step-02" "Remove vSAN Witness Host"
if($vsan_witness_host_vcname){
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
    $hv = Get-Datacenter -Name $witness_dc | Get-VMHost -Name $vsan_witness_host_vcname
    if($? -eq $true){
        $hv | Set-VMHost -State Disconnected -Confirm:$false
        $hv | Remove-VMHost -Confirm:$false
    }
    disconnect_all_vc
}else{
    "Skip"
}

task_message "Step-03" "Remove Witness Host VA"
if($vsan_witness_va_name){
    connect_vc -vc_addr $base_vc_address -vc_user $base_vc_user -vc_pass $base_vc_pass
    $vsan_witness_va = Get-VM $vsan_witness_va_name
    if($? -eq $true){
        $vsan_witness_va | Stop-VM -Confirm:$false
        $vsan_witness_va | Remove-VM -DeletePermanently -Confirm:$false
    }
    disconnect_all_vc
}else{
    "Skip"
}

task_message "Step-04" "Remove ESXi VMs"
connect_vc -vc_addr $base_vc_address -vc_user $base_vc_user -vc_pass $base_vc_pass

"Remove VMs:"
$vm_name_list

$vm_name_list | ForEach-Object {
    $esxi_vm_name = $_
    $esxi_vm = Get-Datacenter $base_dc_name | Get-Folder -Type VM -Name $esxi_vm_folder_name | Get-VM | where {$_.Name -eq $esxi_vm_name} 
    $esxi_vm | Stop-VM -Confirm:$false
    $esxi_vm | Remove-VM -DeletePermanently -Confirm:$false
}
disconnect_all_vc

task_message "Step-05" "Remove VM Folder"
connect_vc -vc_addr $base_vc_address -vc_user $base_vc_user -vc_pass $base_vc_pass
if(-Not $esxi_vm_folder_name){$esxi_vm_folder_name = ("VM_VC-" + $nest_vc_address + "_" + $nest_cluster_name)}
$esxi_vm_folder = Get-Datacenter $base_dc_name | Get-Folder -Type VM -Name $esxi_vm_folder_name
if(($esxi_vm_folder | Get-VM).Count -eq 0){
    $esxi_vm_folder | Remove-Folder -Confirm:$false -ErrorAction:Ignore
}

disconnect_all_vc

task_message "Step-06" "Remove vDS"
if($create_vds -eq $true){
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
    if($? -eq $true){
        Get-VDSwitch $vds_name | Remove-VDSwitch -Confirm:$false
    }
    disconnect_all_vc
}else{
    "Skip"
}
