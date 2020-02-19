# vSAN-Lab Config file

# ----------------------------------------
# Setup flags
$create_esxi_vms       = $true  # $true or $false
$create_vsphre_cluster = $true  # $true or $false
$create_witness_vm     = $false # $true or $false
$create_vsan_wts       = $false # $true or $false
$create_vsan_cluster   = $true  # $true or $false
$create_vsan_2node     = $false # $true or $false

# ----------------------------------------
# Base-vSphere environment config
$env_config = "./configs/base-env/env_home-lab-01.ps1"
Get-Item $env_config -ErrorAction:Stop | fl FullName,LastWriteTime
. $env_config

# ----------------------------------------
# vSAN Cluster settings

$nest_dc_name = "LAB-DC"
$nest_cluster_name = "vSAN-Cluster-01"
$vm_num = 3
$hv_ip_4oct_start = 31 # 4th Octet for ESXi-vmk0-IP

# ----------------------------------------
# Nested ESXi settings

# ESXi Template VM
$template_vm_name = "vm-esxi-template-67u3"

# VM Name / ESXi Hostname Prefix
$vm_name_prefix = "vm-esxi-"
$nest_hv_hostname_prefix = "esxi-"

# ESXi Data host Spec
$esxi_memory_gb = 6

# Nested ESXi User / Password
$hv_user = "root"
$hv_pass = "VMware1!"

# Nested ESXi setting
$domain = "go-lab.jp"
$hv_ip_prefix_vmk0 = "192.168.1." # $hv_ip_prefix_vmk0 + $hv_ip_4oct_start => 192.168.1.31
$hv_vmk0_subnetmask = "255.255.255.0" # /24
$nest_hv_vmk0_vlan = 0 # Default VLAN ID: 0

$hv_gw = "192.168.1.1"
$dns_1 = "192.168.1.101"
$dns_2 = "192.168.1.102"

# ----------------------------------------
# Network additional settings

# Multi vmk setting
$add_vmk1 = $true # $true or $false
$add_vmk2 = $true # $true or $false

$vmotion_vmk_port = "vmk1"
$vsan_vmk_port = "vmk2"
$witness_vmk_port = "" # vSAN WTS only

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

# ----------------------------------------
# vDS Settings

$create_vds = $false
<#
    $vds_name = "vds-01"

    $vds_mgmt_pg_name = "dvpg_" + $vds_name + "_mgmt"
    $vds_mgmt_pg_vlan = 0
    $vds_vmotion_pg_name = "dvpg_" + $vds_name + "_vmotion"
    $vds_vmotion_pg_vlan = 1001
    $vds_vsan_pg_name = "dvpg_" + $vds_name + "_vsan"
    $vds_vsan_pg_vlan = 1002
    $vds_guest_pg_name = "dvpg_" + $vds_name + "_guest"
    $vds_guest_pg_vlan = 0
#>

# ----------------------------------------
# Storage Settings

# vSAN Datastore Name
$vsan_ds_name = "vsanDatastore-01"

# vSAN Disk Group type
$vsan_dg_type = "Hybrid" # Hybrid or AllFlash

# vSAN Disk setting
$vsan_cache_disk_size_gb = 20
$vsan_capacity_disk_size_gb = 50
$vsan_capacity_disk_count = 2
$vsan_dg_count = 2 # Multi-Diskgroup setup

# ----------------------------------------
# vSAN Witness Config

<#
    # Witness VA Base Config
    $base_witness_pg_name_1 = "Nested-Trunk-Network"
    $base_witness_pg_name_2 = "Nested-Trunk-Network"

    # Witness Host Config
    $witness_dc = "LAB-DC"
    $witness_host_folder = "Witness-Hosts" # if "host", it is added to DC
    $vsan_witness_host_name = "esxi-038"
    $vsan_witness_host_domain = "go-lab.jp"
    $vsan_witness_host_ip = "192.168.1.38"
    $vsan_witness_host_subnetmask = "255.255.255.0"
    $vsan_witness_host_gw = "192.168.1.1"
    $vsan_witness_dns_1 = "192.168.1.101"
    $vsan_witness_dns_2 = "192.168.1.102"
    $vsan_witness_host_vcname = $vsan_witness_host_ip

    $vsan_wts = $false # Witness Traffic Separation (WTS): $true or $false
    $vsan_witness_template_name = "VMware-VirtualSAN-Witness-6.7.0.update03-14320388"
    $vsan_witness_va_name = "vm-esxi-witness-" + $vsan_witness_host_ip
#>
