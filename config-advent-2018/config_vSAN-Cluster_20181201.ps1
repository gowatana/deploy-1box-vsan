# Cluster setting
$nest_dc_name = "LAB-DC"
$nest_cluster_name = "vSAN-Cluster-20181201"
$vm_num = 4
$hv_ip_4oct_start = 31 #ESXi-vmk0-IP 4 Octet

# VM / ESXi Prefix
$vm_name_prefix = "vm-esxi-"
$nest_hv_hostname_prefix = "esxi-"

# Nested ESXi setting
$domain = "go-lab.jp"
$hv_ip_prefix_vmk0 = "192.168.1." # $hv_ip_prefix_vmk0 + $hv_ip_4oct_start => 192.168.1.31
$hv_subnetmask = "255.255.255.0" # /24

$hv_gw = "192.168.1.1"
$dns_1 = "192.168.1.101"
$dns_2 = "192.168.1.102"
$hv_user = "root"
$hv_pass = "VMware1!"

# vSAN Disk setting
$vsan_dg_type = "Hybrid" # Hybrid or AllFlash
$vsan_cache_disk_size_gb = 40
$vsan_cache_dev = "mpx.vmhba0:C0:T1:L0"
$vsan_capacity_disk_size_gb = 80
$vsan_capacity_disk_count = 1
$vsan_capacity_dev = "mpx.vmhba0:C0:T2:L0"
