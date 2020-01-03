$hv_ip_4oct = $hv_ip_4oct_start
$vc_hv_name_list | ForEach-Object {
    $hv_name = $_
    $hv_vmk1_ip = $hv_ip_prefix_vmk1 + $hv_ip_4oct
    $hv_vmk2_ip = $hv_ip_prefix_vmk2 + $hv_ip_4oct
    
    task_message "02-02_01" ("Add vSS-Portgroup for vmk1 (vMotion): " + $hv_name)
    add_vss $hv_name $vmotion_vmk_vss $vmotion_vmk_pg $vmotion_vmk_vlan
    
    task_message "02-02_02" ("Add vmk1 port to vSS-PG (vMotion): " + $hv_name)
    add_vss_vmk_port $hv_name $vmotion_vmk_vss $vmotion_vmk_pg $hv_vmk1_ip $hv_vmk1_subnetmask

    task_message "02-02_03" ("Add vSS-Portgroup for vmk2 (vSAN): " + $hv_name)
    add_vss $hv_name $vsan_vmk_vss $vsan_vmk_pg $vsan_vmk_vlan
    
    task_message "02-02_04" ("Add vmk2 port to vSS-PG (vSAN): " + $hv_name)
    add_vss_vmk_port $hv_name $vsan_vmk_vss $vsan_vmk_pg $hv_vmk2_ip $hv_vmk2_subnetmask

    $hv_ip_4oct++
}

task_message "02-02_05" "Enable vMotion vmk-traffic"
Get-VMHost $vc_hv_name_list | Get-VMHostNetworkAdapter -Name $vmotion_vmk_port |
    Set-VMHostNetworkAdapter -VMotionEnabled:$true -Confirm:$false |
    Sort-Object VMHost |
    select VMHost,DeviceName,PortgroupName,VMotionEnabled | ft -AutoSize

    task_message "02-02_06" "Enable vSAN vmk-traffic"
Get-VMHost $vc_hv_name_list | Get-VMHostNetworkAdapter -Name $vsan_vmk_port |
    Set-VMHostNetworkAdapter -VsanTrafficEnabled:$true -Confirm:$false |
    Sort-Object VMHost |
    select VMHost,DeviceName,PortgroupName,VsanTrafficEnabled | ft -AutoSize
