$hv_ip_4oct = $hv_ip_4oct_start
$vc_hv_name_list | ForEach-Object {
    $hv_name = $_

    if($add_vmk1){
        $vmk1_ip = $vmk1_ip_prefix + $hv_ip_4oct
        
        task_message "03-02-01" ("Add vSS-Portgroup for vmk1: " + $hv_name)
        add_vss_pg $hv_name $vmk1_vss $vmk1_pg $vmk1_vlan
        
        task_message "03-02-02" ("Add vmk1 port to vSS-Portgroup: " + $hv_name)
        add_vss_vmk_port $hv_name $vmk1_vss $vmk1_pg $vmk1_ip $vmk1_subnetmask
    }
    
    if($add_vmk2){
        $vmk2_ip = $vmk2_ip_prefix + $hv_ip_4oct

        task_message "03-02-03" ("Add vSS-Portgroup for vmk2: " + $hv_name)
        add_vss_pg $hv_name $vmk2_vss $vmk2_pg $vmk2_vlan
        
        task_message "03-02-04" ("Add vmk2 port to vSS-Portgroup: " + $hv_name)
        add_vss_vmk_port $hv_name $vmk2_vss $vmk2_pg $vmk2_ip $vmk2_subnetmask
    }
    
    $hv_ip_4oct++
}

task_message "03-02-05" ("Enable vMotion vmk-traffic: " + $vmotion_vmk_port)
Get-VMHost $vc_hv_name_list | Get-VMHostNetworkAdapter -Name $vmotion_vmk_port |
    Set-VMHostNetworkAdapter -VMotionEnabled:$true -Confirm:$false |
    Sort-Object VMHost |
    select VMHost,DeviceName,PortgroupName,VMotionEnabled | ft -AutoSize

task_message "03-02-06" ("Enable vSAN vmk-traffic: " + $vsan_vmk_port)
if(($create_vsan_cluster -eq $true) -or ($create_vsan_2node -eq $true)){
    Get-VMHost $vc_hv_name_list | Get-VMHostNetworkAdapter -Name $vsan_vmk_port |
        Set-VMHostNetworkAdapter -VsanTrafficEnabled:$true -Confirm:$false |
        Sort-Object VMHost |
        select VMHost,DeviceName,PortgroupName,VsanTrafficEnabled | ft -AutoSize
} else {
    "Skip"
}
