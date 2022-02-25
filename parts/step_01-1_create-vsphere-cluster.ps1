task_message "01-01-01" "Create vSphere Datacenter"
if (Get-Datacenter -Name $nest_dc_name -ErrorAction:SilentlyContinue){
    "Skip"
}else{
    New-Datacenter -Name $nest_dc_name -Location (Get-Folder -Type Datacenter -Name "Datacenters") -ErrorAction:Stop | Out-Null
}
$nest_dc = Get-Datacenter -Name $nest_dc_name
$nest_dc | select Name

task_message "01-01-02" "Create vSphere Cluster"
$cluster = Get-Datacenter $nest_dc_name | New-Cluster -Name $nest_cluster_name -ErrorAction:Stop | Out-Null
$cluster | select @{N="Datacenter";E={($_ | Get-Datacenter).Name}},@{N="Cluster";E={$_.Name}}
