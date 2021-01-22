# add vSAN Witness Host to vCenter / Config WTS

task_message "06-01-01" "Create DC: $witness_dc"
Get-Folder -Type Datacenter -Name Datacenters | New-Datacenter -Name $witness_dc -ErrorAction:Ignore

task_message "06-01-02" "Create Host Foler: $witness_host_folder"
if($witness_host_folder -ne "host"){
    New-Folder -Location (Get-Datacenter $witness_dc | Get-Folder "host") -Name $witness_host_folder -ErrorAction:Ignore
}

task_message "06-01-03" "Add Witness Host: $vsan_witness_host_vcname"
$loc = Get-Datacenter $witness_dc | Get-Folder -Type HostAndCluster -Name $witness_host_folder
Add-VMHost -Location $loc -Name $vsan_witness_host_vcname -User $hv_user -Password $hv_pass -Force
if((Get-VMHost $vsan_witness_host_vcname) -eq $false){"Add Witness Host Error"; exit 1}

if($setup_vsan_wts -eq $true){
    task_message "06-01-04" "WTS - Enable vSAN Traffic(vmk0): $vsan_witness_host_vcname"
    $vmk = Get-VMHost $vsan_witness_host_vcname | Get-VMHostNetworkAdapter -Name vmk0 |
        Set-VMHostNetworkAdapter -VsanTrafficEnabled:$true -Confirm:$false
    $vmk | select VMHost,DeviceName,Mac,Mtu,VsanTrafficEnabled,PortGroupName,DhcpEnabled,IP,SubnetMask | fl 
    
    task_message "06-01-05" "WTS - Disable vSAN Traffic(vmk1): $vsan_witness_host_vcname"
    $vmk = Get-VMHost $vsan_witness_host_vcname | Get-VMHostNetworkAdapter -Name vmk1 |
        Set-VMHostNetworkAdapter -VsanTrafficEnabled:$false -Confirm:$false  
    $vmk | select VMHost,DeviceName,Mac,Mtu,VsanTrafficEnabled,PortGroupName,DhcpEnabled,IP,SubnetMask | fl  
}

task_message "06-01-06" "Enable TSM-SSH: $vsan_witness_host_vcname"
Get-VMHost $vsan_witness_host_vcname | Get-VMHostService | where {$_.key -eq "TSM-SSH"} | % {
    $_ | Start-VMHostService
    $_ | Set-VMHostService -Policy On
} | Out-Null

Get-VMHost $vsan_witness_host_vcname | Get-VMHostService | where {$_.key -eq "TSM-SSH"} | 
    select VMHost,Key,Label,Policy,Running | ft -AutoSize

task_message "06-01-07" "Suppress SSH Warning TSM-SSH: $vsan_witness_host_vcname"
Get-VMHost $vsan_witness_host_vcname | Get-AdvancedSetting -Name  "UserVars.SuppressShellWarning" |
    Set-AdvancedSetting -Value 1 -Confirm:$false | select Entity,Name,Value

task_message "06-01-08" "Remove VM Folder: Discovered virtual machine"
Get-Folder -Type VM -Name "Discovered virtual machine" |
    where {($_ | Get-VM).Count -eq 0} | Remove-Folder -Confirm:$false

task_message "06-01-09" "Set ESXi DNS Servers"
Get-VMHost $vsan_witness_host_vcname | Get-VMHostNetwork | Set-VMHostNetwork -DnsAddress $vsan_witness_host_dns_servers |
    select HostName,DnsAddress | Sort-Object HostName | ft -AutoSize

task_message "06-01-10" "Add ESXi NTP Servers"
Get-VMHost $vsan_witness_host_vcname | Add-VMHostNtpServer -NtpServer $vsan_witness_host_ntp_servers
Get-VMHost $vsan_witness_host_vcname | select Name,@{N="NtpServers";E={$_|Get-VMHostNtpServer}}
