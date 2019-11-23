$cluster = Get-Cluster -Name $nest_cluster_name

"Enable vSAN:"
$cluster | Set-Cluster -VsanEnabled:$true -Confirm:$false |
    select Name,VsanEnabled

"Create vSAN Disk Group:"
Get-Cluster $nest_cluster_name | Get-VMHost |
    New-VsanDiskGroup -SsdCanonicalName $vsan_cache_dev -DataDiskCanonicalName $vsan_capacity_dev |
    ft -AutoSize VMHost,DiskGroupType,DiskFormatVersion

Get-Cluster $nest_cluster_name | Get-VsanSpaceUsage
