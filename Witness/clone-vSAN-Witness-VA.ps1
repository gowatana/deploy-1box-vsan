# Clone vSAN Witness Virtual Appliance.

# Load Config file.
$config_file_name = $args[0]
. $config_file_name
if($? -eq $false){"config file not found."; exit}

# Clone Nested ESXi VMs
$template_vm_name = $vsan_witness_template_name
$vm_name = $vsan_witness_va_name

$vm = New-VM -VM $template_vm_name -Name $vm_name -VMHost (Get-VMHost $base_hv_name) -StorageFormat Thin
Get-VM $vm_name | Get-NetworkAdapter -Name "*2" | Set-NetworkAdapter -StartConnected:$false -Confirm:$false
Get-VM $vm_name | Start-VM | ft -AutoSize Name,VMHost,PowerState

"waiting for VM startup."
sleep 30

# PowerOn Check
Get-VM $vm_name | % {
    $vm = $_
    $vm_name = $vm.Name
    for (){
        $vm = Get-VM $vm_name
        (Get-Date).DateTime + " " + $vm_name
        if($vm.Guest.ExtensionData.ToolsStatus -eq "toolsOk"){
            break
        }
        sleep 5
    }
}

Get-VM $vm_name | select `
    Name,
    PowerState,
    @{N="ToolsStatus";E={$_.Guest.ExtensionData.ToolsStatus}} |
    Sort-Object Name | ft -AutoSize
