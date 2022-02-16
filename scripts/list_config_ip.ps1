#
# PowerCLI>  ./scripts/list_config_ip.ps1 ./configs-homelab/cluster
#

$config_dir = $args[0]
$config_dir_name = (Get-Item $config_dir -ErrorAction:Stop).Name
$output_dir = "./csv"
$output_csv = (Join-Path $output_dir $config_dir_name) + ".csv"

#$output_table = @()

ls $config_dir | % {
    $config_file = Join-Path $config_dir $_.Name

    ls $config_file | Out-Null
    if($? -eq $false){"vSAN-Lab config file not found."; exit}
    . $config_file | Out-Null
    
    Get-Item $env_config -ErrorAction:Stop | fl FullName,LastWriteTime | Out-Null
    . $env_config

    # set parts script directory.
    $parts_path = "./parts"

    # Load Functions
    . "$parts_path/functions.ps1"

    # Generate VM / ESXi List
    $vm_name_list = @(gen_vm_name_list $vm_num $hv_ip_4oct_start $hv_ip_prefix_vmk0)
    $nest_hv_hostname_list = @(gen_nest_hv_hostname_list $vm_num $hv_ip_4oct_start $nest_hv_hostname_prefix)
    $hv_ip_vmk0_list = @(gen_hv_ip_vmk0_list $vm_num $hv_ip_4oct_start $hv_ip_prefix_vmk0)
    $vc_hv_name_list = @($hv_ip_vmk0_list)
    
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
    }
} | Export-Csv -Path $output_csv
