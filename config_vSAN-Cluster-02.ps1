# Lab Global Setting.
$base_vc_address = "192.168.1.30"
$base_vc_user = "administrator@vsphere.local"
$base_vc_pass = "VMware1!"

$nest_vc_address = "192.168.1.30"
$nest_vc_user = "administrator@vsphere.local"
$nest_vc_pass = "VMware1!"

$domain = "go.lab.jp"
$hv_ip_prefix_vmk0 = "192.168.1."
$hv_subnetmask = "255.255.255.0" # /24
$hv_gw = "192.168.1.1"
$dns_1 = "192.168.1.101"
$dns_2 = "192.168.1.102"
$hv_user = "root"
$hv_pass = "VMware1!"

# Base ESXi Setting
$template_vm_name = "vm-esxi-template-01"
$base_hv_name = "192.168.1.20"

# Cluster setting
$vm_num_start = 4
$vm_num_end = 6
$cluster_name = "vSAN-Cluster-02"

# vSAN Disk setting
$vsan_cache_dev = "mpx.vmhba0:C0:T1:L0"
$vsan_capacity_dev = "mpx.vmhba0:C0:T2:L0", "mpx.vmhba0:C0:T3:L0"

# VM / ESXi List
$nest_hv_hostname_prefix = "esxi-"
$vm_name_prefix = "vm-esxi-"

$vm_name_list = $vm_num_start..$vm_num_end | % {
    $i = $_
    $vm_name_prefix + $i.toString("00")
}

$nest_hv_hostname_list = $vm_num_start..$vm_num_end | % {
    $i = $_
    $nest_hv_hostname_prefix + $i.toString("00")
}

$hv_ip_vmk0_list = $vm_num_start..$vm_num_end | % {
    $i = $_
    $hv_ip_prefix_vmk0 + (30 + $i).ToString()
}

$vc_hv_name_list = $vm_num_start..$vm_num_end | % {
    $i = $_
    $hv_ip_prefix_vmk0 + (30 + $i).ToString()
}

