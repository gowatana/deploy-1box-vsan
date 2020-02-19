$cluster = Get-Cluster -Name $nest_cluster_name

task_message "20-01-01" "Test vSAN Health"
Get-Cluster $nest_cluster_name | Test-VsanClusterHealth |
    select Cluster,TimeOfTest,OverallHealthStatus,OverallHealthDescription | fl

task_message "20-01-02" "List vSAN Datastore Space Usage"
Get-Cluster $nest_cluster_name | Get-VsanSpaceUsage
