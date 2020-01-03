$cluster = Get-Cluster -Name $nest_cluster_name

task_message "03-01_01" "Add SSD Mark to Cache device"
$cluster | Get-VMHost | Sort-Object Name | ForEach-Object {
    $hv = $_
    $vsan_cache_dev = get_candidate_device -esxi $hv -dev_type "Cache"
    ("Cache Device: " + $vsan_cache_dev)
    set_satp_rule -esxi $hv -dev_list $vsan_cache_dev -satp_rule_option "enable_ssd"
}

task_message "03-01_02" ("Add SSD Mark to Capacity device: " + $vsan_dg_type)
$satp_ssd_rule = "enable_ssd"
if($vsan_dg_type -eq "Hybrid"){$satp_ssd_rule = "disable_ssd"}
$cluster | Get-VMHost | Sort-Object Name | ForEach-Object {
    $hv = $_
    $vsan_capacity_dev = get_candidate_device -esxi $hv -dev_type "Capacity"
    ("Capacity Device: " + $vsan_capacity_dev)
    set_satp_rule -esxi $hv -dev_list $vsan_capacity_dev -satp_rule_option $satp_ssd_rule
}
