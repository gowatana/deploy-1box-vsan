$cluster = Get-Cluster -Name $nest_cluster_name

task_message "10-01-01" "SCSI Rescan"
$cluster | Get-VMHost | Sort-Object Name | ForEach-Object {
    $hv = $_
    Get-VMHost $hv | Get-VMHostStorage -RescanAllHba
}

task_message "10-01-02" "Add SSD Mark to Cache device"
$cluster | Get-VMHost | Sort-Object Name | ForEach-Object {
    $hv = $_
    $vsan_dev = get_candidate_device -esxi $hv -dev_type "Cache"
    ("Cache Device: " + $vsan_dev)
    mark_as_ssd -esxi $hv -dev_list $vsan_dev -mark_device_ssd $true
}

task_message "10-01-03" ("Add SSD Mark to Capacity device: " + $vsan_dg_type)
$is_ssd = $false
if($vsan_dg_type -eq "AllFlash"){$is_ssd = $true}
$cluster | Get-VMHost | Sort-Object Name | ForEach-Object {
    $hv = $_
    $vsan_dev = get_candidate_device -esxi $hv -dev_type "Capacity"
    ("Capacity Device: " + $vsan_dev)
    mark_as_ssd -esxi $hv -dev_list $vsan_dev -mark_device_ssd $is_ssd
}
