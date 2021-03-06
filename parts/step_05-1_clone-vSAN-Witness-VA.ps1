# Clone vSAN Witness Virtual Appliance.

$vm_name = $vsan_witness_va_name

if(-Not $esxi_vm_folder_name){$esxi_vm_folder_name = ("VM_VC-" + $nest_vc_address + "_" + $nest_cluster_name)}
$esxi_vm_folder = Get-Folder -Type VM -Name $esxi_vm_folder_name

$base_rp = Get-Datacenter $base_dc_name | Get-Cluster -Name $base_cluster_name | Get-ResourcePool -Name "Resources" | 
    Get-ResourcePool -Name $base_rp_name | select -First 1

task_message "05-01-01" ("Clone Witness VM: " + $vm_name)
$vm = New-VM -VM $vsan_witness_template_name -Name $vm_name -ResourcePool $base_rp -Location $esxi_vm_folder -Datastore $base_ds_name -StorageFormat Thin
$vm | select Name,NumCpu,MemoryGB,Folder,VMHost,HardwareVersion,GuestId | Format-List

task_message "05-01-02" ("Set Portgroup to vNIC#1: " + $vm_name)
if(-not $base_witness_pg_name_1){
    $base_witness_pg_name_1 = $base_pg_name
    Write-Host 'DEBUG: $base_witness_pg_name_1 = $base_pg_name'
}
$base_witness_pg_1 = Get-VMHost $base_hv_name | Get-VirtualPortGroup -Name $base_witness_pg_name_1
$vm | Get-NetworkAdapter -Name "* 1" | Set-NetworkAdapter -Portgroup $base_witness_pg_1 -Confirm:$false |
    select Parent,Name,NetworkName | ft -AutoSize

task_message "05-01-03" ("Set Portgroup to vNIC#2: " + $vm_name)
if(-not $base_witness_pg_name_2){
    $base_witness_pg_name_2 = $base_pg_name
    Write-Host 'DEBUG: $base_witness_pg_name_2 = $base_pg_name'
}
$base_witness_pg_2 = Get-VMHost $base_hv_name | Get-VirtualPortGroup -Name $base_witness_pg_name_2
$vm | Get-NetworkAdapter -Name "* 2" | Set-NetworkAdapter -Portgroup $base_witness_pg_2 -Confirm:$false |
    select Parent,Name,NetworkName | ft -AutoSize

task_message "05-01-04" ("Disconnect All vNICs: " + $vm_name)
$vm | Get-NetworkAdapter | Set-NetworkAdapter -StartConnected:$false -Confirm:$false |
    Sort-Object Name | select Parent,Name,NetworkName,@{N="StartConnected";E={$_.ConnectionState.StartConnected}} | ft -AutoSize

task_message "05-01-05" ("Start VM: " + $vm_name)
$vm | Start-VM | ft -AutoSize Name,VMHost,PowerState

task_message "05-01-06" ("waiting for VM startup. 30s")
$vm_poweron_check_wait_sec = 30
$vm_poweron_check_interval_sec = 5
Start-Sleep $vm_poweron_check_wait_sec

task_message "05-01-07" ("VM PowerOn Check")
(Get-VM $vm_name | Sort-object Name) | % {
    $vm = $_
    $vm_name = $vm.Name
    for (){
        $vm = Get-VM $vm_name
        (Get-Date).DateTime + " " + $vm_name
        if($vm.Guest.ExtensionData.ToolsStatus -eq "toolsOk"){
            Write-Host "toolsOk"
            break
        }
        Start-Sleep $vm_poweron_check_interval_sec
    }
}

task_message "05-01-08" ("List ToolsStatus")
Get-VM $vm_name | select `
    Name,
    PowerState,
    @{N="ToolsStatus";E={$_.Guest.ExtensionData.ToolsStatus}} |
    Sort-Object Name | ft -AutoSize
