$cluster = Get-Datacenter $nest_dc_name | Get-Cluster -Name $nest_cluster_name

$vc_hv_name_list | % {
    $hv_name = $_
    
    task_message "03-01-01a" "Add ESXi to Cluster: $hv_name"
    Add-VMHost -Name $hv_name -Location $cluster -User $hv_user -Password $hv_pass -Force | select `
        Name,
        NumCpu,
        @{N="MemoryGB";E={[int]$_.MemoryTotalGB}},
        Version,
        Build,
        ConnectionState |
        Format-List

    task_message "03-01-01b" "Enter Maintenance Mode: $hv_name"
    $cluster | Get-VMHost $hv_name | Set-VMHost -State Maintenance -Confirm:$false |
    select Name,ConnectionState | Format-List

    task_message "03-01-02" "Remove Default Local VMFS Datastore: $hv_name"
    $local_ds_name = "datastore*"
    if($cluster | Get-VMHost $hv_name | Get-Datastore -Name $local_ds_name){
        $cluster | Get-VMHost $hv_name | Remove-Datastore -Datastore $local_ds_name -Confirm:$false -ErrorAction:Ignore
    }else{
        "Skip"
    }
}

task_message "03-01-03" "Set UserVars.SuppressShellWarning = 1"
$cluster | Get-VMHost | Get-AdvancedSetting -Name "UserVars.SuppressShellWarning" |
    Set-AdvancedSetting -Value 1 -Confirm:$false |
    select Entity,Name,Value | Sort-Object Entity | ft -AutoSize

task_message "03-01-04" "Remove VM Folder: Discovered virtual machine"
Get-Folder -Type VM -Name "Discovered virtual machine" |
    where {($_ | Get-VM).Count -eq 0} | Remove-Folder -Confirm:$false

task_message "03-01-05" "Set ESXi DNS Servers"
$cluster | Get-VMHost | Get-VMHostNetwork | Set-VMHostNetwork -DnsAddress $dns_servers |
    select HostName,DnsAddress | Sort-Object HostName | ft -AutoSize

task_message "03-01-06" "Add ESXi NTP Servers"
$cluster | Get-VMHost | Add-VMHostNtpServer -NtpServer $ntp_servers
$cluster | Get-VMHost | Sort-Object Name | select Name,@{N="NtpServers";E={$_|Get-VMHostNtpServer}}

task_message "03-01-07" "Start ESXi NTP Service"
$cluster | Get-VMHost | Get-VMHostService | where {$_.key -eq "ntpd"} | Set-VMHostService -Policy on
$cluster | Get-VMHost | Get-VMHostService | where {$_.key -eq "ntpd"} | Start-VMHostService
$cluster | Get-VMHost | Get-VMHostService | where {$_.key -eq "ntpd"} | 
    select VMHost,Key,Policy,Running | Sort-Object VMHost | ft -AutoSize
