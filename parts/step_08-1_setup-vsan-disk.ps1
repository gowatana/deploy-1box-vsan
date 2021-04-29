$cluster = Get-Cluster -Name $nest_cluster_name

task_message "08-01-01" "Add SSD Mark to Cache device"
$cluster | Get-VMHost | Sort-Object Name | ForEach-Object {
    $hv = $_
    $vsan_dev = get_candidate_device -esxi $hv -dev_type "Cache"
    ("Cache Device: " + $vsan_dev)
    mark_as_ssd -esxi $hv -dev_list $vsan_dev -mark_device_ssd $true
}

task_message "08-01-02" ("Add SSD Mark to Capacity device: " + $vsan_dg_type)
$is_ssd = $false
if($vsan_dg_type -eq "AllFlash"){$is_ssd = $true}
$cluster | Get-VMHost | Sort-Object Name | ForEach-Object {
    $hv = $_
    $vsan_dev = get_candidate_device -esxi $hv -dev_type "Capacity"
    ("Capacity Device: " + $vsan_dev)
    mark_as_ssd -esxi $hv -dev_list $vsan_dev -mark_device_ssd $is_ssd
}
