# Cluster config file

$create_vsphre_cluster = $true # $true or $false
$create_vsan_cluster   = $true # $true or $false

# Cluster setting
$nest_dc_name = "LAB-DC"
$nest_cluster_name = "vSAN-Cluster-20191210"
$vm_num = 3
$hv_ip_4oct_start = 31 #ESXi-vmk0-IP 4 Octet

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
$vmotion_vmk_port = "vmk1"
$vmotion_vmk_vss = "vSwitch0"
$vmotion_vmk_pg = "pg_vmk_vmotion"
$vmotion_vmk_vlan = 1001

$vsan_vmk_port = "vmk2"
$vsan_vmk_vss = "vSwitch0"
$vsan_vmk_pg = "pg_vmk_vsan"
$vsan_vmk_vlan = 1002

$hv_ip_prefix_vmk1 = "10.0.1." # $hv_ip_prefix_vmk1 + $hv_ip_4oct_start => 10.0.1.31
$hv_vmk1_subnetmask = "255.255.255.0" # /24

$hv_ip_prefix_vmk2 = "10.0.2." # $hv_ip_prefix_vmk2 + $hv_ip_4oct_start => 10.0.2.31
$hv_vmk2_subnetmask = "255.255.255.0" # /24

# vSAN Disk setting
$vsan_dg_type = "Hybrid" # Hybrid or AllFlash
$vsan_cache_disk_size_gb = 40
$vsan_cache_dev = "mpx.vmhba0:C0:T1:L0"
$vsan_capacity_disk_size_gb = 300
$vsan_capacity_disk_count = 1
$vsan_capacity_dev = "mpx.vmhba0:C0:T2:L0"
