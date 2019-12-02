$cluster = Get-Cluster -Name $nest_cluster_name

#task_message "03-02_01" ("Enable vSAN Traffic")
#$vmk_port_for_vsan = "vmk0"
#$cluster | Get-VMHost | Get-VMHostNetworkAdapter -Name $vmk_port_for_vsan | 
#    Set-VMHostNetworkAdapter -VsanTrafficEnabled:$true -Confirm:$false |
#    Sort-Object VMHost | select VMHost,DeviceName,Mac,IP,SubnetMask,VsanTrafficEnabled | ft -AutoSize

task_message "03-02_02" ("Enable vSAN")
$cluster | Set-Cluster -VsanEnabled:$true -Confirm:$false |
    select Name,VsanEnabled

task_message "03-02_03" ("Create vSAN Disk Group")
Get-Cluster $nest_cluster_name | Get-VMHost |
    New-VsanDiskGroup -SsdCanonicalName $vsan_cache_dev -DataDiskCanonicalName $vsan_capacity_dev |
    Sort-Object VMHost | select VMHost,DiskGroupType,DiskFormatVersion | ft -AutoSize

task_message "03-02_04" ("List vSAN Datastore Space Usage")
Get-Cluster $nest_cluster_name | Get-VsanSpaceUsage
