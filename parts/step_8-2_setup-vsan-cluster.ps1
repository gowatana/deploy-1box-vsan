$cluster = Get-Cluster -Name $nest_cluster_name

task_message "08-02-01" "Enable vSAN"
$cluster | Set-Cluster -VsanEnabled:$true -Confirm:$false |
    select Name,VsanEnabled

task_message "08-02-02" "Change vSAN Datastore Name"
if($vsan_ds_name){
    $cluster | Get-Datastore | where {$_.Type -eq "vsan"} | Set-Datastore -Name $vsan_ds_name
}else{
    "Skip"
}

task_message "08-02-03" "Create vSAN Disk Group"
Get-Cluster $nest_cluster_name | Get-VMHost | Sort-Object VMHost | ForEach-Object {
    $hv = $_
    $vsan_cache_dev = get_candidate_device -esxi $hv -dev_type "Cache"
    $vsan_capacity_dev = get_candidate_device -esxi $hv -dev_type "Capacity"
    $hv | New-VsanDiskGroup -SsdCanonicalName $vsan_cache_dev -DataDiskCanonicalName $vsan_capacity_dev       
} | select VMHost,DiskGroupType,DiskFormatVersion | ft -AutoSize
