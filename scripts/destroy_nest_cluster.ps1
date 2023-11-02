# Load Functions
. ./parts/functions.ps1

# Generate VM / ESXi List
$vm_name_list = gen_vm_name_list $vm_num $hv_ip_4oct_start $hv_ip_prefix_vmk0
if($nest_hv_hostname_list -eq $null){
    $nest_hv_hostname_list = gen_nest_hv_hostname_list $vm_num $hv_ip_4oct_start $nest_hv_hostname_prefix
}
$hv_ip_vmk0_list = gen_hv_ip_vmk0_list $vm_num $hv_ip_4oct_start $hv_ip_prefix_vmk0
$vc_hv_name_list = $hv_ip_vmk0_list

# fix VM Folder name
if(-Not $esxi_vm_folder_name){$esxi_vm_folder_name = ("VM_VC-" + $nest_vc_address + "_" + $nest_cluster_name)}

# Disconnect from All vCeners
disconnect_all_vc

task_message "Step-101" "Remove vSAN Cluster and ESXi"
connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
$cluster = Get-Datacenter $nest_dc_name | Get-Cluster $nest_cluster_name
if($? -eq $true){
    $cluster | Get-VMHost | Set-VMHost -State Disconnected -Confirm:$false
    $cluster | Get-VMHost | Remove-VMHost -Confirm:$false
    $cluster | Remove-Cluster -Confirm:$false
}
disconnect_all_vc

task_message "Step-102" "Remove vSAN Witness Host"
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

task_message "Step-103" "Remove vDS"
if($create_vds -eq $true){
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
    if($? -eq $true){
        $vds = Get-Datacenter -Name $nest_dc_name | Get-VDSwitch -Name $vds_name
        if(($vds | Get-VMHost).Count -eq 0){
            $vds | Remove-VDSwitch -Confirm:$false -ErrorAction:Ignore
        }   
    }
    disconnect_all_vc
}else{
    "Skip"
}
