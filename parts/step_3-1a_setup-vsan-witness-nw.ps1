$cluster = Get-Cluster -Name $nest_cluster_name

task_message "03a-01_01" ("Add Witness tag: $witness_vmk_port on $hv")
$cluster | Get-VMHost | Sort-Object Name | ForEach-Object {
    $hv = $_
    set_vmk_witness_tag -esxi $hv -vmk_port $witness_vmk_port
}
