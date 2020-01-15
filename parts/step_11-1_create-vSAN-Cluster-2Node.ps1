# Enable 2-Node vSAN Cluster

$fd_preferred = "Preferred"
$fd_secondary = "Secondary"
$cache_device_name = "mpx.vmhba0:C0:T1:L0"
$capacity_device_name = "mpx.vmhba0:C0:T2:L0"

task_message "11-01-01" "Create Fault Domain (Preferred)"
New-VsanFaultDomain -Name $fd_preferred -VMHost $vc_hv_name_list[0] |
    select Cluster,Name

task_message "11-01-02" "Create Fault Domain (Secondary)"
New-VsanFaultDomain -Name $fd_secondary -VMHost $vc_hv_name_list[1] |
    select Cluster,Name

task_message "11-01-03" "Enable 2-Node Stretched Cluster"
$witness_host = Get-VMHost $vsan_witness_host_vcname
$cache_device = $witness_host | Get-VMHostDisk | where {$_.ScsiLun.CanonicalName -eq $cache_device_name}
$capacity_device = $witness_host | Get-VMHostDisk | where {$_.ScsiLun.CanonicalName -eq $capacity_device_name}

Get-Cluster $nest_cluster_name | Set-VsanClusterConfiguration `
    -StretchedClusterEnabled:$true `
    -WitnessHost $witness_host `
    -PreferredFaultDomain $fd_preferred `
    -WitnessHostCacheDisk $cache_device `
    -WitnessHostCapacityDisk $capacity_device |
    select Cluster,StretchedClusterEnabled,PreferredFaultDomain,WitnessHost | fl
