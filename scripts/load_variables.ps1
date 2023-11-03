$config_file = $args[0]

# ----------------------------------------
# Functions
function gen_vm_name_list($vm_num, $hv_ip_4oct_start, $hv_ip_prefix_vmk0) {
    $hv_ip_4oct = $hv_ip_4oct_start  
    for($i=1; $i -le $vm_num; $i++){  
        $vm_name_prefix + $hv_ip_prefix_vmk0 + $hv_ip_4oct.ToString()
        $hv_ip_4oct++
    } 
}

function gen_nest_hv_hostname_list($vm_num, $hv_ip_4oct_start, $nest_hv_hostname_prefix) {   
    $hv_ip_4oct = $hv_ip_4oct_start
    for($i=1; $i -le $vm_num; $i++){
        $nest_hv_hostname_prefix + $hv_ip_4oct.toString("000")
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

function output_config_timestamp($config_file_name) {
    Get-Item $config_file_name -ErrorAction:Stop | %{
        Write-Host (" FullName: " + $_.FullName)
        Write-Host (" LastWriteTime: " + $_.LastWriteTime)
        Write-Host ""
    }
}

# ----------------------------------------
# Load vSAN-Lab config file.
ls $config_file | Out-Null
if($? -eq $false){"Lab config file not found."; exit}
. $config_file

# Fix Config file path
$config_dir = (Get-ChildItem $config_file).DirectoryName
$base_vc_config = Join-Path $config_dir $base_vc_config
$nest_vc_config = Join-Path $config_dir $nest_vc_config
$base_env_config = Join-Path $config_dir $base_env_config
$nest_env_config = Join-Path $config_dir $nest_env_config
$vds_config = Join-Path $config_dir $vds_config
$witness_config = Join-Path $config_dir $witness_config

"Load Base-vCenter Configs"
output_config_timestamp($base_vc_config)
. $base_vc_config
$base_vc_address = $vc_address
$base_vc_user = $vc_user
$base_vc_pass = $vc_pass

"Load Nest-vCenter Configs"
output_config_timestamp($nest_vc_config)
. $nest_vc_config
$nest_vc_address = $vc_address
$nest_vc_user = $vc_user
$nest_vc_pass = $vc_pass

"Load Base-vSphere Config file:"
output_config_timestamp($base_env_config)
. $base_env_config

"Load Nest-vSphere Config file:"
output_config_timestamp($nest_env_config)
. $nest_env_config

"Load vDS-vSphere Config file:"
if($create_vds -eq $true){
    output_config_timestamp($vds_config)
    . $vds_config
}else{
    "- Skip"
}

"Load vSAN-Witness-VA Config file:"
if($create_witness_vm -eq $true){   
    output_config_timestamp($witness_config)
    . $witness_config
}else{
    "- Skip"
}

# Generate VM / ESXi List
$vm_name_list = @(gen_vm_name_list $vm_num $hv_ip_4oct_start $hv_ip_prefix_vmk0)
if($nest_hv_hostname_list.Count -eq 0){
    $nest_hv_hostname_list = @(gen_nest_hv_hostname_list $vm_num $hv_ip_4oct_start $nest_hv_hostname_prefix)
}
$hv_ip_vmk0_list = @(gen_hv_ip_vmk0_list $vm_num $hv_ip_4oct_start $hv_ip_prefix_vmk0)
if($vc_hv_name_use_fqdn){
    $vc_hv_name_list = @($nest_hv_hostname_list)
}else{
    $vc_hv_name_list = @($hv_ip_vmk0_list)
}

# Adjast Setup Flag
if($create_vsan_cluster -eq $true){$create_vsphre_cluster = $true}
if($create_vsphre_cluster -eq $true){$create_esxi_vms = $true}
