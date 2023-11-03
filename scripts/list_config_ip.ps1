#
# PowerCLI>  ./scripts/list_config_ip.ps1 ./configs-homelab/cluster ./csv
#

$config_dir = $args[0]
$output_dir = $args[1]
$config_dir_name = (Get-Item $config_dir -ErrorAction:Stop).Name
$output_csv = (Join-Path $output_dir $config_dir_name) + ".csv"

$conifg_file_list = @(Get-ChildItem $config_dir/*.ps1 | % { $_.FullName })
$conifg_file_list

# set parts script directory.
$parts_path = "./parts"

# Load Functions
. "$parts_path/functions.ps1"

rm $output_csv -ErrorAction:SilentlyContinue

$tab = "" | select `
    config_file,
    base_vc_address,
    base_dc_name,
    base_cluster_name,
    base_rp_name,
    base_hv_name,
    nest_vc_address,
    nest_dc_name,
    nest_cluster_name,
    template_vm_name,
    vm_num,
    vm_name,
    vc_hv_name,
    nest_hv_hostname,
    hv_ip_vmk0

$esxi_vm_table = @()

$conifg_file_list | % {
    $config_file = $_
    
    # Load vSAN-Lab config file.
    ls $config_file | Out-Null
    if($? -eq $false){"Lab config file not found."; exit}
    . ./scripts/load_variables.ps1 $config_file

    $tab.config_file = $config_file
    $tab.base_vc_address = $base_vc_address
    $tab.base_dc_name = $base_dc_name
    $tab.base_cluster_name = $base_cluster_name
    $tab.base_rp_name = $base_rp_name
    $tab.base_hv_name = $base_hv_name

    $tab.nest_vc_address = $nest_vc_address
    $tab.nest_dc_name = $nest_dc_name
    $tab.nest_cluster_name = $nest_cluster_name
    $tab.template_vm_name = $template_vm_name

    1..$vm_num | %{
        $tab.vm_num = $_
        $vm_count = $_ - 1
        $tab.vm_name = $vm_name_list[$vm_count]
        $tab.nest_hv_hostname = $nest_hv_hostname_list[$vm_count]
        $tab.hv_ip_vmk0 = $hv_ip_vmk0_list[$vm_count]
        $tab.vc_hv_name = $vc_hv_name_list[$vm_count]
        $tab
        $tab | Export-Csv -Path $output_csv -NoTypeInformation -Append
    }
}

