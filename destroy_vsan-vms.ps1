
# Load Config file.
$config_file_name = $args[0]
. $config_file_name
if($? -eq $false){"config file not found."; exit}

$cluster = Get-Cluster $cluster_name
$cluster | Get-VMHost | Set-VMHost -State Disconnected -Confirm:$false
$cluster | Get-VMHost | Remove-VMHost -Confirm:$false
$cluster | Remove-Cluster -Confirm:$false

Get-VM $vm_name_list | Stop-VM -Confirm:$false
Get-VM $vm_name_list | Remove-VM -DeletePermanently -Confirm:$false
