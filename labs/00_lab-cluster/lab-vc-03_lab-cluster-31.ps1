# vSAN-Lab Config file

# ----------------------------------------
# Setup flags
$create_esxi_vms       = $true  # $true or $false
$create_vsphre_cluster = $true  # $true or $false
$create_vds            = $false # $true or $false
$create_witness_vm     = $false # $true or $false
$setup_vsan_wts        = $false # $true or $false (WTS: Witness Traffic Separation)
$create_vsan_cluster   = $false # $true or $false
$create_vsan_2node     = $false # $true or $false

# ----------------------------------------
# Common settings
#$config_base = Split-Path -Path $PSScriptRoot -Parent
$config_base = "./labs"

# ----------------------------------------
# Base Environment configs

# Base-vCenter Login config
$base_vc_config = "$config_base/01_vcenter-login/infra-vc-01.ps1"

# Base-vSphere environment config
$base_env_config = "$config_base/02_base-vsphere/infra-dc-01_infra-cluster-01.ps1"

# ----------------------------------------
# Nest Environment configs

# Nest-vCenter Login config
$nest_vc_config = "$config_base/01_vcenter-login/lab-vc-03.ps1"

# Nest-vSphere environment config
$nest_env_config = "$config_base/03_nest-vsphere/lab-cluster-31.ps1"

# ----------------------------------------
# Additional configs

# vDS Settings
$vds_config = "$config_base/04_vds/lab-vds-03.ps1"

# vSAN Witness Config
$witness_config = "$config_base/05_vsan-witness/conf_Witness-VA_X.ps1"
