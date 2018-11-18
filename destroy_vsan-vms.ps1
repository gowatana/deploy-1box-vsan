
# Load Config file.
$config_file_name = $args[0]
. $config_file_name
if($? -eq $false){"config file not found."; exit}
. $config_file_name

Disconnect-VIServer * -Confirm:$false -Force -ErrorAction:SilentlyContinue
Connect-VIServer -Server $base_vc_address `
    -User $base_vc_user -Password $base_vc_pass -Force
$cluster = Get-Cluster $cluster_name
$cluster | Get-VMHost | Set-VMHost -State Disconnected -Confirm:$false
$cluster | Get-VMHost | Remove-VMHost -Confirm:$false
$cluster | Remove-Cluster -Confirm:$false
Disconnect-VIServer * -Confirm:$false

Connect-VIServer -Server $nest_vc_address `
    -User $nest_vc_user -Password $nest_vc_pass -Force
Get-VM $vm_name_list | Stop-VM -Confirm:$false
Get-VM $vm_name_list | Remove-VM -DeletePermanently -Confirm:$false
Disconnect-VIServer * -Confirm:$false