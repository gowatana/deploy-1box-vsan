$cluster = Get-Cluster -Name $nest_cluster_name

task_message "10-01-01" "SCSI Rescan"
if($vsan_arch -eq "OSA"){
    $cluster | Get-VMHost | Sort-Object Name | ForEach-Object {
        $hv = $_
        Get-VMHost $hv | Get-VMHostStorage -RescanAllHba
    }
}else{
    "Skip"
}

task_message "10-01-02" "Add SSD Mark to Cache device"
if($vsan_arch -eq "OSA"){
    $cluster | Get-VMHost | Sort-Object Name | ForEach-Object {
        $hv = $_
        $vsan_dev = get_candidate_device -esxi $hv -dev_type "Cache"
        ("Cache Device: " + $vsan_dev)
        mark_as_ssd -esxi $hv -dev_list $vsan_dev -mark_device_ssd $true
    }else{
        "Skip"
    }
}

task_message "10-01-03" ("Add SSD Mark to Capacity device: " + $vsan_dg_type)
if($vsan_arch -eq "OSA"){
    $is_ssd = $false
    if($vsan_dg_type -eq "AllFlash"){$is_ssd = $true}
    $cluster | Get-VMHost | Sort-Object Name | ForEach-Object {
        $hv = $_
        $vsan_dev = get_candidate_device -esxi $hv -dev_type "Capacity"
        ("Capacity Device: " + $vsan_dev)
        mark_as_ssd -esxi $hv -dev_list $vsan_dev -mark_device_ssd $is_ssd
    }else{
        "Skip"
    }
}
