# Clone vSAN Witness Virtual Appliance.

$template_vm_name = $vsan_witness_template_name
$vm_name = $vsan_witness_va_name

task_message "Witness-1-02" ("Clone Witness VM: " + $vm_name)
$vm = New-VM -VM $template_vm_name -Name $vm_name -VMHost (Get-VMHost $base_hv_name) -Datastore $base_ds_name -StorageFormat Thin
$vm | select Name,NumCpu,MemoryGB,Folder,VMHost, Version, GuestId | Format-List

task_message "Witness-1-03" ("Set vNIC#1: " + $vm_name)
$vm | Get-NetworkAdapter -Name "* 1" | Set-NetworkAdapter -Portgroup (Get-VMHost $base_hv_name | Get-VirtualPortGroup -Name $base_pg_name) -Confirm:$false |
    select Parent,Name,NetworkName | ft -AutoSize

#task_message "Witness-1-0N" ("Set vNIC#2: " + $vm_name)
#$vm | Get-NetworkAdapter -Name "* 2" | Set-NetworkAdapter -Portgroup (Get-VMHost $base_hv_name | Get-VirtualPortGroup -Name $base_pg_name) -Confirm:$false |
#    select Parent,Name,NetworkName | ft -AutoSize

task_message "Witness-1-04" ("Disconnect All vNICs: " + $vm_name)
$vm | Get-NetworkAdapter | Set-NetworkAdapter -StartConnected:$false -Confirm:$false |
    select Parent,Name,NetworkName,@{N="StartConnected";E={$_.ConnectionState.StartConnected}} | ft -AutoSize

task_message "Witness-1-05" ("Start VM: " + $vm_name)
$vm | Start-VM | ft -AutoSize Name,VMHost,PowerState

task_message "Witness-1-06" ("waiting for VM startup. 30s")
$vm_poweron_check_wait_sec = 30
$vm_poweron_check_interval_sec = 5
Start-Sleep $vm_poweron_check_wait_sec

task_message "Witness-1-07" ("VM PowerOn Check")
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

task_message "Witness-1-08" ("List ToolsStatus")
Get-VM $vm_name | select `
    Name,
    PowerState,
    @{N="ToolsStatus";E={$_.Guest.ExtensionData.ToolsStatus}} |
    Sort-Object Name | ft -AutoSize
