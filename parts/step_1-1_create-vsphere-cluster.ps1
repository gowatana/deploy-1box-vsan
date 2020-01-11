task_message "01-01-01" "Create vSphere Cluster"
$cluster = Get-Datacenter $nest_dc_name | New-Cluster -Name $nest_cluster_name -ErrorAction:Stop
$cluster | select @{N="Datacenter";E={($_ | Get-Datacenter).Name}},@{N="Cluster";E={$_.Name}}
