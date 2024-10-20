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

$n = 0
for($i=1; $i -le $vm_num; $i++){ 
    $vm_name = @($vm_name_list)[$n]
    $nest_hv_hostname = @($nest_hv_hostname_list)[$n]
    $hv_ip_vmk0 = @($hv_ip_vmk0_list)[$n]
    $n += 1
    
    task_message "02-02-01" ("Configure Nested ESXi: " + $vm_name)
    if(-Not $nest_hv_vmk0_vlan){$nest_hv_vmk0_vlan = 0}
    # esxcli ...
    "system hostname set --host $nest_hv_hostname --domain $domain",
    "network ip interface ipv4 set --interface-name=vmk0 --type=static --ipv4=$hv_ip_vmk0 --netmask=$hv_vmk0_subnetmask --gateway=$hv_gw",
    "network vswitch standard portgroup set -p 'Management Network' -v $nest_hv_vmk0_vlan",
    "network ip route ipv4 add --network=0.0.0.0/0 --gateway=$hv_gw" |
    ForEach-Object {
        nested_esxcli -ESXiVM:$vm_name -ESXiUser:$hv_user -ESXiPass:$hv_pass -ESXCLICmd $_
        sleep 1
    }
    
    task_message "02-02-02" ("Connect All vNICs: " + $vm_name)
    Get-VM -Name $vm_name | Get-NetworkAdapter | Set-NetworkAdapter -StartConnected:$true -Connected:$true -Confirm:$false |
    select Parent,Name,NetworkName,@{N="StartConnected";E={$_.ConnectionState.StartConnected}} | ft -AutoSize

    task_message "02-02-03" ("ESXi VM Network Connectivity workaround: " + $vm_name)
    # esxcli ...
    "network diag ping -c 2 -H $hv_gw" |
    ForEach-Object {
        nested_esxcli -ESXiVM:$vm_name -ESXiUser:$hv_user -ESXiPass:$hv_pass -ESXCLICmd $_
        sleep 1
    }

    task_message "02-02-04" ("Configure Nested ESXi DNS Server: " + $vm_name)
    # esxcli ...
    $dns_servers | ForEach-Object {
        $dns_server = $_
        Write-Host "Set DNS Server: $dns_server"
        $esxcli_cmd = "network ip dns server add --server=$dns_server"
        nested_esxcli -ESXiVM:$vm_name -ESXiUser:$hv_user -ESXiPass:$hv_pass -ESXCLICmd $esxcli_cmd
        sleep 1
    }

    task_message "02-02-05" ("Configure Nested ESXi DNS Search: " + $vm_name)
    # esxcli ...
    Write-Host "Set DNS Search: $domain"
    $esxcli_cmd = "network ip dns search add --domain=$domain"
    nested_esxcli -ESXiVM:$vm_name -ESXiUser:$hv_user -ESXiPass:$hv_pass -ESXCLICmd $esxcli_cmd
    sleep 1 

    task_message "02-02-06" ("Configure Nested ESXi NTP Server: " + $vm_name)
    # esxcli ...
    $ntp_server_list = ""
    $ntp_servers | ForEach-Object {
        $ntp_server = $_
        $ntp_server_list = $ntp_server_list + " --server=$ntp_server"
    }
    $esxcli_cmd = "system ntp set --enabled=1" + $ntp_server_list
    nested_esxcli -ESXiVM:$vm_name -ESXiUser:$hv_user -ESXiPass:$hv_pass -ESXCLICmd $esxcli_cmd
    sleep 1


    task_message "02-02-07" ("Generate ESXi Self-Certificate: " + $vm_name)
    # Check Posh-SSH Install.
    if(-Not (Get-Module Posh-SSH -ListAvailable)){
        $enable_gen_esxi_cert = $false
    }
    
    if($enable_gen_esxi_cert -eq $true){
        $ssh_password = ConvertTo-SecureString $hv_pass -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential ($hv_user, $ssh_password)

        $Session = New-SSHSession -ComputerName $hv_ip_vmk0 -Credential $Credential -AcceptKey

        if ($Session) {   
            $CommandResult = Invoke-SSHCommand -SessionId 0 -Command "/sbin/generate-certificates"
            $CommandResult.Output
            Start-Sleep 1

            $CommandResult = Invoke-SSHCommand -SessionId 0 -Command "/etc/init.d/hostd restart"
            $CommandResult.Output
            Start-Sleep 1

            $CommandResult = Invoke-SSHCommand -SessionId 0 -Command "/etc/init.d/vpxa restart"
            $CommandResult.Output
            Start-Sleep 1

            $CommandResult = Invoke-SSHCommand -SessionId 0 -Command "/etc/init.d/rhttpproxy restart"
            $CommandResult.Output

        } else {
            Write-Host "SSH-NG - Skip: Generate ESXi Self-Certificate"
        }

        Remove-SSHSession -SessionId $Session.SessionId
    }else{
        "Skip"
    }
}
