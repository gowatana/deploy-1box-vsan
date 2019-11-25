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
#. ./parts/generate_obj_lists.ps1
$vm_name_list = gen_vm_name_list $vm_num $hv_ip_4oct_start
$nest_hv_hostname_list = gen_nest_hv_hostname_list $vm_num $hv_ip_4oct_start $nest_hv_hostname_prefix
$hv_ip_vmk0_list = gen_hv_ip_vmk0_list $vm_num $hv_ip_4oct_start $hv_ip_prefix_vmk0
$vc_hv_name_list = $hv_ip_vmk0_list

# Disconnect from All vCeners
disconnect_all_vc

# Remove vSAN Cluster
Connect-VIServer -Server $nest_vc_address `
    -User $nest_vc_user -Password $nest_vc_pass -Force
$cluster = Get-Cluster $nest_cluster_name
$cluster | Get-VMHost | Set-VMHost -State Disconnected -Confirm:$false
$cluster | Get-VMHost | Remove-VMHost -Confirm:$false
$cluster | Remove-Cluster -Confirm:$false
# Remove Witness Host / DC
if($vsan_witness_host){
    Get-VMHost $vsan_witness_host | Set-VMHost -State Disconnected -Confirm:$false
    Get-VMHost $vsan_witness_host | Remove-VMHost -Confirm:$false
    if((Get-Datacenter $witness_dc | Get-VMHost).Count -eq 0){
        Remove-Datacenter $witness_dc -Confirm:$false
    }    
}
Disconnect-VIServer $nest_vc_address -Confirm:$false

# Remove ESXi VMs
Connect-VIServer -Server $base_vc_address `
    -User $base_vc_user -Password $base_vc_pass -Force
Get-VM $vm_name_list | Stop-VM -Confirm:$false
Get-VM $vm_name_list | Remove-VM -DeletePermanently -Confirm:$false
if($vsan_witness_va_name){
    Get-VM $vsan_witness_va_name | Stop-VM -Confirm:$false
    Get-VM $vsan_witness_va_name | Remove-VM -DeletePermanently -Confirm:$false    
}
Disconnect-VIServer $base_vc_address -Confirm:$false
