# Load Config file.
$config_file_name = $args[0]
. $config_file_name
if($? -eq $false){"config file not found."; exit}

Get-Folder -Type Datacenter | New-Datacenter $witness_dc
Get-Datacenter $witness_dc | Add-VMHost -Name $vsan_witness_host -User $hv_user -Password $hv_pass -Force
Get-VMHost $vsan_witness_host | Remove-Datastore -Datastore "datastore*" -Confirm:$false -ErrorAction:Ignore

Get-VMHost $vsan_witness_host | Get-VMHostNetworkAdapter -Name vmk0 |
    Set-VMHostNetworkAdapter -VsanTrafficEnabled:$true -Confirm:$false

Get-VMHost $vsan_witness_host | Get-VMHostNetworkAdapter -Name vmk1 |
    Set-VMHostNetworkAdapter -VsanTrafficEnabled:$false -Confirm:$false

New-VsanFaultDomain -Name "Preferred" -VMHost $vc_hv_name_list[0]
New-VsanFaultDomain -Name "Secondary" -VMHost $vc_hv_name_list[1]

Get-Cluster $nest_cluster_name | 
    Set-VsanClusterConfiguration -StretchedClusterEnabled:$true `
        -WitnessHost $vsan_witness_host `
        -WitnessHostCacheDisk "mpx.vmhba1:C0:T2:L0" `
        -WitnessHostCapacityDisk "mpx.vmhba1:C0:T1:L0" `
        -PreferredFaultDomain "Preferred"

# Get-VMHost 192.168.1.29 | Get-VMHostService | where {$_.key -eq "TSM-SSH"} | Start-VMHostService
