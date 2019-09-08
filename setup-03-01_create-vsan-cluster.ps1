# Load Config file.
$config_file_name = $args[0]
. $config_file_name
if($? -eq $false){"config file not found."; exit}

$cluster = Get-Datacenter $nest_dc_name | New-Cluster -Name $nest_cluster_name


$vc_hv_name_list | % {
    $hv_name = $_

    "Add ESXi to Cluster: " + $hv_name
    Add-VMHost -Name $hv_name -Location $cluster -User $hv_user -Password $hv_pass -Force | select `
        Name,
        NumCpu,
        @{N="MemoryGB";E={[int]$_.MemoryTotalGB}},
        Version,
        Build,
        State |
        Format-List
    Get-VMHost $hv_name | Remove-Datastore -Datastore "datastore*" -Confirm:$false -ErrorAction:Ignore
}

"Enable vSAN Traffic: "
$cluster | Get-VMHost | Get-VMHostNetworkAdapter -Name vmk0 | 
    Set-VMHostNetworkAdapter -VsanTrafficEnabled:$true -Confirm:$false |
    ft -AutoSize VMHost,DeviceName,Mac,IP,SubnetMask,VsanTrafficEnabled