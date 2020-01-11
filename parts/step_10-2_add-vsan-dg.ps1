$cluster = Get-Cluster -Name $nest_cluster_name

task_message "05-03_01" "Create vSAN Disk Group"
Get-Cluster $nest_cluster_name | Get-VMHost | Sort-Object VMHost | ForEach-Object {
    $hv = $_
    $vsan_cache_dev = get_candidate_device -esxi $hv -dev_type "Cache"
    $vsan_capacity_dev = get_candidate_device -esxi $hv -dev_type "Capacity"
    $hv | New-VsanDiskGroup -SsdCanonicalName $vsan_cache_dev -DataDiskCanonicalName $vsan_capacity_dev       
} | select VMHost,DiskGroupType,DiskFormatVersion | ft -AutoSize
