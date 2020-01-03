$cluster = Get-Cluster -Name $nest_cluster_name

task_message "03-02_01" "Enable vSAN"
$cluster | Set-Cluster -VsanEnabled:$true -Confirm:$false |
    select Name,VsanEnabled


task_message "03-02_02" "Change vSAN Datastore Name"
if(-Not $vsan_ds_name){
    $cluster | Get-Datastore | where {$_.Type -eq "vsan"} | Set-Datastore -Name $vsan_ds_name
}

task_message "03-02_03" "Create vSAN Disk Group"
Get-Cluster $nest_cluster_name | Get-VMHost |
    New-VsanDiskGroup -SsdCanonicalName $vsan_cache_dev -DataDiskCanonicalName $vsan_capacity_dev |
    Sort-Object VMHost | select VMHost,DiskGroupType,DiskFormatVersion | ft -AutoSize

task_message "03-02_04" "Test vSAN Health"
Get-Cluster $nest_cluster_name | Test-VsanClusterHealth |
    select Cluster,TimeOfTest,OverallHealthStatus,OverallHealthDescription | fl

task_message "03-02_05" "List vSAN Datastore Space Usage"
Get-Cluster $nest_cluster_name | Get-VsanSpaceUsage
