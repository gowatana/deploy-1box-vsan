# WIP

New-VsanFaultDomain -Name "Preferred" -VMHost $vc_hv_name_list[0]
New-VsanFaultDomain -Name "Secondary" -VMHost $vc_hv_name_list[1]

Get-Cluster $nest_cluster_name | 
    Set-VsanClusterConfiguration -StretchedClusterEnabled:$true `
        -WitnessHost $vsan_witness_host `
        -WitnessHostCacheDisk "mpx.vmhba1:C0:T2:L0" `
        -WitnessHostCapacityDisk "mpx.vmhba1:C0:T1:L0" `
        -PreferredFaultDomain "Preferred"
