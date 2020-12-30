task_message "04-01-01" "Create vDS"
$vds = New-VDSwitch -Name $vds_name -Location (Get-Datacenter $nest_dc_name) -NumUplinkPorts 2 -ErrorAction:SilentlyContinue
$vds = Get-Datacenter -Name $nest_dc_name | Get-VDSwitch -Name $vds_name
$vds

task_message "04-01-02" "Create vDS Portgroup: Management"
$vds | New-VDPortgroup -Name $vds_mgmt_pg_name -VlanId $vds_mgmt_pg_vlan |
    select VDSwitch,Name,VlanConfiguration | ft -AutoSize

task_message "04-01-03" "Create vDS Portgroup: vMotion"
$vds | New-VDPortgroup -Name $vds_vmotion_pg_name -VlanId $vds_vmotion_pg_vlan |
select VDSwitch,Name,VlanConfiguration | ft -AutoSize

task_message "04-01-04" "Create vDS Portgroup: vSAN"
$vds | New-VDPortgroup -Name $vds_vsan_pg_name -VlanId $vds_vsan_pg_vlan |
select VDSwitch,Name,VlanConfiguration | ft -AutoSize

task_message "04-01-05" "Create vDS Portgroup: Guest OS"
$vds | New-VDPortgroup -Name $vds_guest_pg_name -VlanId $vds_guest_pg_vlan |
select VDSwitch,Name,VlanConfiguration | ft -AutoSize

task_message "04-01-06" "List vDS Portgroup"
Get-VDSwitch $vds_name | Get-VDPortgroup |
    select VDSwitch,Name,VlanConfiguration | ft -AutoSize

$hvs = Get-Datacenter $nest_dc_name | Get-Cluster $nest_cluster_name | Get-VMHost
$hvs | Sort-Object Name | ForEach-Object {
    $hv = $_
    task_message "04-01-07" ("Add ESXi to vDS: " + $hv.Name)
    Add-VDSwitchVMHost -VDSwitch $vds -VMHost $hv

    task_message "04-01-08" ("Migrate vmnic0 and vmk0 to vDS: " + $hv.Name)
    $vmk = $hv | Get-VMHostNetworkAdapter -VMKernel -Name "vmk0"
    $vmnic = $hv | Get-VMHostNetworkAdapter -Physical -Name "vmnic0"
    Add-VDSwitchPhysicalNetworkAdapter -DistributedSwitch $vds `
        -VirtualNicPortgroup $vds_mgmt_pg_name -VMHostVirtualNic $vmk `
        -VMHostPhysicalNic $vmnic -Confirm:$false
    
    task_message "04-01-09" ("Migrate vmk1 to vDS: " + $hv.Name)
    if($add_vmk1){
        $hv | Get-VMHostNetworkAdapter -VMKernel -Name "vmk1" |
            Set-VMHostNetworkAdapter -PortGroup $vds_vmotion_pg_name -Confirm:$false
    }else{
        "Skip"
    }
    
    task_message "04-01-10" ("Migrate vmk2 to vDS: " + $hv.Name)
    if($add_vmk2){
        $hv | Get-VMHostNetworkAdapter -VMKernel -Name "vmk2" |
            Set-VMHostNetworkAdapter -PortGroup $vds_vsan_pg_name -Confirm:$false
    }else{
        "Skip"
    }
    
    task_message "04-01-11" ("Remove vSwitch0: " + $hv.Name)
    $hv | Get-VirtualSwitch -Name "vSwitch0" | Remove-VirtualSwitch -Confirm:$false
}
