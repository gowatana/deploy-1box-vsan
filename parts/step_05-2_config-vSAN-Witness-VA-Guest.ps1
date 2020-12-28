# Setup Witness-VA Guest
function nested_esxcli {
    param(
        $ESXiVM, $ESXiUser, $ESXiPass, $ESXCLICmd
    )

    $vm = Get-VM $ESXiVM | select -First 1
    "ESXi VM Name:" + $vm.Name

    $vm_id = $vm.Id
    $vc_name = $vm.Uid  -replace "^.*@|:.*$",""
    $vc = $global:DefaultVIServers | where {$_.Name -eq $vc_name}

    # set Authentication info.
    $cred = New-Object VMware.Vim.NamePasswordAuthentication
    $cred.Username = $ESXiUser
    $cred.Password = $ESXiPass

    # set esxcli.
    $gps = New-Object VMware.Vim.GuestProgramSpec
    $gps.WorkingDirectory = "/tmp"
    $gps.ProgramPath = "/bin/esxcli"
    $gps.Arguments = $ESXCLICmd

    # Invoke Guest Command.
    $gom = Get-View $vc.ExtensionData.Content.GuestOperationsManager
    $pm = Get-View $gom.ProcessManager
    $gos_pid = $pm.StartProgramInGuest($vm_Id, $cred, $gps)
    $pm.ListProcessesInGuest($vm_Id, $cred, $gos_pid) | % {$_.CmdLine}
}

$vm_name = $vsan_witness_va_name
$nest_hv_hostname = $vsan_witness_host_name
$domain = $vsan_witness_host_domain
$hv_ip_vmk0 = $vsan_witness_host_ip
$hv_subnetmask = $vsan_witness_host_subnetmask
$hv_gw = $vsan_witness_host_gw

task_message "05-02-01" ("Configure Nested ESXi: " + $vm_name)
# esxcli ...
"system hostname set --host $nest_hv_hostname --domain $domain",
"network ip interface ipv4 set --interface-name=vmk0 --type=static --ipv4=$hv_ip_vmk0 --netmask=$hv_subnetmask --gateway=$hv_gw",
"network vswitch standard portgroup set -p 'Management Network' -v $vsan_witness_host_vlan",
"network ip route ipv4 add --network=0.0.0.0/0 --gateway=$hv_gw" |
ForEach-Object {
    nested_esxcli -ESXiVM:$vm_name -ESXiUser:$vsan_witness_host_user -ESXiPass:$vsan_witness_host_pass -ESXCLICmd $_
    sleep 1
}

task_message "05-02-02" ("Connect All vNICs: " + $vm_name)
Get-VM -Name $vm_name | Get-NetworkAdapter | Set-NetworkAdapter -StartConnected:$true -Connected:$true -Confirm:$false |
    select Parent,Name,NetworkName,@{N="StartConnected";E={$_.ConnectionState.StartConnected}} | ft -AutoSize

task_message "05-02-03" ("ESXi VM Network Connectivity workaround: " + $vm_name)
# esxcli ...
"network diag ping -c 2 -H $hv_gw" |
ForEach-Object {
    nested_esxcli -ESXiVM:$vm_name -ESXiUser:$hv_user -ESXiPass:$hv_pass -ESXCLICmd $_
    sleep 1
}
