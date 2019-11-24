# ----------------------------------------
# Format output

function task_message($task_id, $task_message) {
    ""
    "=" * 80
    "// Task_ID: " + $task_id.toString()
    "// Message: " + $task_message
}

# ----------------------------------------
# Generate VM / ESXi List

function gen_vm_name_list($vm_num,$hv_ip_4oct_start) {
    $hv_ip_4oct = $hv_ip_4oct_start  
    for($i=1; $i -le $vm_num; $i++){  
        $vm_name_prefix + $hv_ip_4oct.toString("000")
        $hv_ip_4oct++
    } 
}

function gen_nest_hv_hostname_list($vm_num, $hv_ip_4oct_start, $nest_hv_hostname_prefix) {   
    $hv_ip_4oct = $hv_ip_4oct_start
    for($i=1; $i -le $vm_num; $i++){      
        $nest_hv_hostname_prefix + $hv_ip_4oct.toString("00")
        $hv_ip_4oct++
    } 
}

function gen_hv_ip_vmk0_list($vm_num, $hv_ip_4oct_start, $hv_ip_prefix_vmk0) {   
    $hv_ip_4oct = $hv_ip_4oct_start
    for($i=1; $i -le $vm_num; $i++){
        $hv_ip_prefix_vmk0 + $hv_ip_4oct.ToString()
        $hv_ip_4oct++
    } 
}

function disconnect_all_vc() {
    $global:DefaultVIServers | ForEach-Object {
        $vc = $_
        "Disconnect from VC: " + $vc.Name
        $vc | Disconnect-VIServer -Confirm:$false
    }
}

# ----------------------------------------
# Nested ESXi/vSAN Tips

function set_satp_rule {
    param (
        $esxi,
        $dev_list,
        $satp_rule_name = "VMW_SATP_LOCAL",
        $satp_rule_option = "disable_ssd"
    )

    $esxcli = $esxi | Get-EsxCli -V2
    $dev_list | % {
        $dev_name = $_
        "ESXi SATP Setting: " + `
            $hv.Name + " " + $satp_rule_name + " " + $satp_rule_option
        $config = $esxcli.storage.nmp.satp.rule.add.CreateArgs()
    
        $config.satp = $satp_rule_name
        $config.device = $dev_name
        $config.option = $satp_rule_option
        $esxcli.storage.nmp.satp.rule.add.Invoke($config)
        
        $config = $esxcli.storage.core.claiming.reclaim.CreateArgs()
        $config.device = $dev_name
        $esxcli.storage.core.claiming.reclaim.Invoke($config)
    }
}
