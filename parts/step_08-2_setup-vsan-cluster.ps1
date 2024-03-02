$cluster = Get-Cluster -Name $nest_cluster_name

task_message "08-02-01" "Enable vSAN"
if($vsan_arch -eq "OSA"){
    "Enable vSAN OSA"
    $cluster | Set-Cluster -VsanEnabled:$true -Confirm:$false |
        select Name,VsanEnabled,VsanEsaEnabled
}else{
    "Enable vSAN ESA"
    $cluster | Set-Cluster -VsanEnabled:$true -VsanEsaEnabled:$true -Confirm:$false |
        select Name,VsanEnabled,VsanEsaEnabled
}

task_message "08-02-02" "Create vSAN Disk Group"
if($vsan_arch -eq "OSA"){
    Get-Cluster $nest_cluster_name | Get-VMHost | Sort-Object VMHost | ForEach-Object {
        $hv = $_
        $vsan_cache_dev = get_candidate_device -esxi $hv -dev_type "Cache"
        $vsan_capacity_dev = get_candidate_device -esxi $hv -dev_type "Capacity"
        $hv | New-VsanDiskGroup -SsdCanonicalName $vsan_cache_dev -DataDiskCanonicalName $vsan_capacity_dev       
    } | select VMHost,DiskGroupType,DiskFormatVersion | ft -AutoSize
}else{
    # for vSAN ESA
    "Skip"
}

task_message "08-02-02a" "Add vSAN Disk to Storage Pool"
if($vsan_arch -eq "ESA"){
    Get-Cluster $nest_cluster_name | Get-VMHost | Sort-Object VMHost | ForEach-Object {
        $hv = $_
        $nvme_canonical_names = $hv |
            Get-VMHostDisk | select -ExpandProperty ScsiLun | where {$_.Vendor -eq "NVMe"} | %{$_.CanonicalName}
        $hv | Add-VsanStoragePoolDisk -VsanStoragePoolDiskType singleTier -DiskCanonicalNames $nvme_canonical_names
    }
}else{
    # for vSAN OSA
    "Skip"
}

task_message "08-02-03" "Change vSAN Datastore Name"
if($vsan_ds_name){
    $cluster | Get-Datastore | where {$_.Type -eq "vsan"} | Set-Datastore -Name $vsan_ds_name
}else{
    "Skip"
}
