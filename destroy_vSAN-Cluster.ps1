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

# Disconnect from All vCeners
disconnect_all_vc

task_message "Destroy-01-Start" "Remove vSAN Cluster and ESXi"
Connect-VIServer -Server $nest_vc_address `
    -User $nest_vc_user -Password $nest_vc_pass -Force
$cluster = Get-Datacenter $nest_dc_name | Get-Cluster $nest_cluster_name
if($? -eq $true){
    $cluster | Get-VMHost | Set-VMHost -State Disconnected -Confirm:$false
    $cluster | Get-VMHost | Remove-VMHost -Confirm:$false
    $cluster | Remove-Cluster -Confirm:$false
}

task_message "Destroy-01-End" "Remove vSAN Cluster and ESXi"
disconnect_all_vc

task_message "Destroy-02-Start" "Remove vSAN Witness Host"
Connect-VIServer -Server $nest_vc_address `
    -User $nest_vc_user -Password $nest_vc_pass -Force |
    select Name,Version,Build,IsConnected | Format-List
$hv = Get-Datacenter -Name $witness_dc | Get-VMHost -Name $vsan_witness_host_vcname
if($? -eq $true){
    $hv | Set-VMHost -State Disconnected -Confirm:$false
    $hv | Remove-VMHost -Confirm:$false
}

task_message "Destroy-02-End" "Remove vSAN Witness Host"
disconnect_all_vc

task_message "Destroy-03-Start" "Remove Witness Host VA"
Connect-VIServer -Server $base_vc_address `
    -User $base_vc_user -Password $base_vc_pass -Force |
    select Name,Version,Build,IsConnected | Format-List
if($vsan_witness_va_name){
    $vsan_witness_va = Get-VM $vsan_witness_va_name
    if($? -eq $true){
        $vsan_witness_va | Stop-VM -Confirm:$false
        $vsan_witness_va | Remove-VM -DeletePermanently -Confirm:$false
    }
}

task_message "Destroy-03-End" "Remove Witness Host VA"
disconnect_all_vc

task_message "Destroy-04-Start" "Remove ESXi VMs / vSAN Witness VA"
Connect-VIServer -Server $base_vc_address `
    -User $base_vc_user -Password $base_vc_pass -Force |
    select Name,Version,Build,IsConnected | Format-List

"Remove VMs:"
$vm_name_list

$vm_name_list | ForEach-Object {
    $esxi_vm_name = $_
    $esxi_vm = Get-Datacenter $base_dc_name | Get-VM | where {$_.Name -eq $esxi_vm_name} 
    $esxi_vm | Stop-VM -Confirm:$false
    $esxi_vm | Remove-VM -DeletePermanently -Confirm:$false
}


task_message "Destroy-04-End" "Remove ESXi VMs / vSAN Witness VA"
disconnect_all_vc
