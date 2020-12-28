$cluster = Get-Cluster -Name $nest_cluster_name
$cluster | Get-VMHost | Sort-Object Name | ForEach-Object {
    $hv = $_
    task_message "07-01-01" ("Add Witness tag: $witness_vmk_port on $hv")
    set_vmk_witness_tag -esxi $hv -vmk_port $witness_vmk_port
}
