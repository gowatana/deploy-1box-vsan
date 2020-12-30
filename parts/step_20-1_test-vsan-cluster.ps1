$cluster = Get-Cluster -Name $nest_cluster_name

task_message "20-01-00" "Exit Maintenance Mode: $hv_name"
$cluster | Get-VMHost | Sort-Object Name | Set-VMHost -State Connected -Confirm:$false |
select Name,ConnectionState | Format-List

task_message "20-01-01" "Test vSAN Health"
if((Get-Command Test-VsanClusterHealth).Version -eq "12.0.0.15939648"){
    "Skip - Test-VsanClusterHealth issue workaround for PowerCLI 12"
}else{
    Get-Cluster $nest_cluster_name | Test-VsanClusterHealth |
        select Cluster,TimeOfTest,OverallHealthStatus,OverallHealthDescription | fl
}

task_message "20-01-02" "List vSAN Datastore Space Usage"
Get-Cluster $nest_cluster_name | Get-VsanSpaceUsage
