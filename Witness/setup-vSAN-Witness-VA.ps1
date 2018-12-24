# https://communities.vmware.com/people/gowatana/blog/2018/04/23/powercli-vsan-witness


# Load Config file.
$config_file_name = $args[0]
. $config_file_name
if($? -eq $false){"config file not found."; exit}

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
$hv_ip_vmk0 = $vsan_witness_host

# esxcli ...
"system hostname set --host $nest_hv_hostname --domain $domain",
"network ip interface ipv4 set --interface-name=vmk0 --type=static --ipv4=$hv_ip_vmk0 --netmask=$hv_subnetmask --gateway=$hv_gw",
"network ip route ipv4 add --network=0.0.0.0/0 --gateway=$hv_gw",
"network ip dns server add --server=$dns_1",
"network ip dns server add --server=$dns_2" |
# "vsan network ip add -i vmk0 -T=witness" |
% {
    nested_esxcli -ESXiVM:$vm_name -ESXiUser:$hv_user -ESXiPass:$hv_pass -ESXCLICmd $_
    sleep 1
}
