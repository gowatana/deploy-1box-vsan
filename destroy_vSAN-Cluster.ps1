
# Load Config file.
$config_file_name = $args[0]
. $config_file_name
if($? -eq $false){"config file not found."; exit}

# Disconnect from All vCeners
$global:DefaultVIServers | % {
    $vc = $_
    "Disconnect from VC: " + $vc.Name
    $vc | Disconnect-VIServer -Confirm:$false
}

# Remove vSAN Cluster
Connect-VIServer -Server $nest_vc_address `
    -User $nest_vc_user -Password $nest_vc_pass -Force
$cluster = Get-Cluster $cluster_name
$cluster | Get-VMHost | Set-VMHost -State Disconnected -Confirm:$false
$cluster | Get-VMHost | Remove-VMHost -Confirm:$false
$cluster | Remove-Cluster -Confirm:$false
# Remove Witness Host / DC
Get-VMHost $vsan_witness_host | Set-VMHost -State Disconnected -Confirm:$false
Get-VMHost $vsan_witness_host | Remove-VMHost -Confirm:$false
if((Get-Datacenter $witness_dc | Get-VMHost).Count -eq 0){
    Remove-Datacenter $witness_dc -Confirm:$false
}
Disconnect-VIServer * -Confirm:$false

Connect-VIServer -Server $base_vc_address `
    -User $base_vc_user -Password $base_vc_pass -Force
Get-VM $vm_name_list | Stop-VM -Confirm:$false
Get-VM $vm_name_list | Remove-VM -DeletePermanently -Confirm:$false
Get-VM $vsan_witness_va_name | Stop-VM -Confirm:$false
Get-VM $vsan_witness_va_name | Remove-VM -DeletePermanently -Confirm:$false
Disconnect-VIServer * -Confirm:$false
