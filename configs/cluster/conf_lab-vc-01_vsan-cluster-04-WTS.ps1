# vSAN-Lab Config file

# ----------------------------------------
# Setup flags
$create_esxi_vms       = $true  # $true or $false
$create_vsphre_cluster = $true  # $true or $false
$create_vds            = $false # $true or $false
$create_witness_vm     = $true  # $true or $false
$setup_vsan_wts        = $true  # $true or $false (WTS: Witness Traffic Separation)
$create_vsan_cluster   = $true  # $true or $false
$create_vsan_2node     = $true  # $true or $false

# ----------------------------------------
# Base-vSphere environment config
$config_base = Split-Path -Path $PSScriptRoot -Parent
$env_config = "$config_base/base-env/env_lab-vc-01.ps1"
Get-Item $env_config -ErrorAction:Stop | fl FullName,LastWriteTime
. $env_config

$base_rp_name = "rp-05-nested-lab"

# ----------------------------------------
# vSAN Cluster settings

$nest_dc_name = "lab-dc-01"
$nest_cluster_name = "vsan-cluster-04"
$vm_num = 2
$hv_ip_4oct_start = 137 # 4th Octet for ESXi-vmk0-IP

# ----------------------------------------
# Nested ESXi settings

# ESXi Template VM
$template_vm_name = "esxi70u1-template-01"
$linked_clone = $true

# VM Name / ESXi Hostname Prefix
$vm_name_prefix = "vm-vsan70u1-esxi-"
$nest_hv_hostname_prefix = "lab-vsan70u1-esxi-"

# ESXi Data host Spec
$esxi_memory_gb = 12

# Nested ESXi User / Password
$hv_user = "root"
$hv_pass = "VMware1!"

# Nested ESXi setting
$domain = "go-lab.jp"
$hv_ip_prefix_vmk0 = "192.168.10." # $hv_ip_prefix_vmk0 + $hv_ip_4oct_start => 192.168.1.31
$hv_vmk0_subnetmask = "255.255.255.0" # /24
$nest_hv_vmk0_vlan = 10 # Default VLAN ID: 0

$hv_gw = "192.168.10.1"
$dns_servers = "192.168.1.101","192.168.1.102"
$ntp_servers = "192.168.1.101","192.168.1.102"

# ----------------------------------------
# Network additional settings

# Multi vmk setting
$add_vmk1 = $true # $true or $false
$add_vmk2 = $True # $true or $false

$vmotion_vmk_port = "vmk1"
$vsan_vmk_port = "vmk2"
$witness_vmk_port = "vmk0" # vSAN WTS only

$vmk1_vss = "vSwitch0"
$vmk1_pg = "pg_vmk_vmotion"
$vmk1_vlan = 1001
$vmk1_ip_prefix = "10.0.1." # $hv_ip_prefix_vmk1 + $hv_ip_4oct_start => 10.0.1.31
$vmk1_subnetmask = "255.255.255.0" # /24

$vmk2_vss = "vSwitch0"
$vmk2_pg = "pg_vmk_vsan"
$vmk2_vlan = 1002
$vmk2_ip_prefix = "10.0.2." # $hv_ip_prefix_vmk2 + $hv_ip_4oct_start => 10.0.2.31
$vmk2_subnetmask = "255.255.255.0" # /24

$multi_vmnic = 4 # add vmnic1 .. vmnic3

# ----------------------------------------
# vDS Settings
$vds_config = (Split-Path -Path $PSScriptRoot -Parent) + "/vds/conf_lab-vds-01.ps1"

# ----------------------------------------
# Storage Settings

# vSAN Datastore Name
$vsan_ds_name = "vsanDatastore-04"

# vSAN Disk Group type
$vsan_dg_type = "Hybrid" # Hybrid or AllFlash

# vSAN Disk setting
$vsan_cache_disk_size_gb = 50
$vsan_capacity_disk_size_gb = 100
$vsan_capacity_disk_count = 1
$vsan_dg_count = 1 # Multi-Diskgroup setup

# ----------------------------------------
# vSAN Witness Config
$witness_config = (Split-Path -Path $PSScriptRoot -Parent) + "/witness/conf_Witness-VA_192.168.10.139.ps1"

