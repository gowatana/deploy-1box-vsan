$cluster = Get-Datacenter $nest_dc_name | New-Cluster -Name $nest_cluster_name -ErrorAction:Stop

$vc_hv_name_list | % {
    $hv_name = $_
    
    task_message "02-01_01" ("Add ESXi to Cluster: " + $hv_name)
    Add-VMHost -Name $hv_name -Location $cluster -User $hv_user -Password $hv_pass -Force | select `
        Name,
        NumCpu,
        @{N="MemoryGB";E={[int]$_.MemoryTotalGB}},
        Version,
        Build,
        State |
        Format-List

    task_message "02-01_02" ("Remove Default Local VMFS Datastore: " + $hv_name)
    Get-VMHost $hv_name | Remove-Datastore -Datastore "datastore*" -Confirm:$false -ErrorAction:Ignore
}

task_message "02-01_03" ("Set UserVars.SuppressShellWarning = 1")
$cluster | Get-VMHost | Get-AdvancedSetting -Name "UserVars.SuppressShellWarning" |
    Set-AdvancedSetting -Value 1 -Confirm:$false |
    select Entity,Name,Value | Sort-Object Entity | ft -AutoSize
