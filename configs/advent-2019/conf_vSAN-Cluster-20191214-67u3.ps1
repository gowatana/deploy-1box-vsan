# vSAN-Lab Config file

$create_vsphre_cluster = $true # $true or $false
$create_vsan_cluster   = $true # $true or $false

# Base-vSphere environment config
. ./configs/base-env/env_home-lab-01.ps1

# Cluster setting
$nest_dc_name = "LAB-DC"
$nest_cluster_name = "vSAN-Cluster-20191214-67u3"
$vm_num = 3
$hv_ip_4oct_start = 34 #ESXi-vmk0-IP 4 Octet

# VM / ESXi Prefix
$vm_name_prefix = "vm-esxi-"
$nest_hv_hostname_prefix = "esxi-"

# Nested ESXi setting
$domain = "go-lab.jp"
$hv_ip_prefix_vmk0 = "192.168.1." # $hv_ip_prefix_vmk0 + $hv_ip_4oct_start => 192.168.1.31
$hv_vmk0_subnetmask = "255.255.255.0" # /24

$hv_gw = "192.168.1.1"
$dns_1 = "192.168.1.101"
$dns_2 = "192.168.1.102"
$hv_user = "root"
$hv_pass = "VMware1!"

# Multi vmk setting
$add_vmk1 = $true # $true or $false
$add_vmk2 = $true # $true or $false

$vmotion_vmk_port = "vmk1"
$vsan_vmk_port = "vmk2"

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

# vSAN Disk setting
$vsan_dg_type = "Hybrid" # Hybrid or AllFlash
$vsan_cache_disk_size_gb = 40
$vsan_cache_dev = "mpx.vmhba0:C0:T1:L0"
$vsan_capacity_disk_size_gb = 300
$vsan_capacity_disk_count = 1
$vsan_capacity_dev = "mpx.vmhba0:C0:T2:L0"

# Change ESXi Template VM
$template_vm_name = "vm-esxi-template-67u3"

# vSAN Datastore Name
$vsan_ds_name = "vsanDatastore-20191214-67u3"
