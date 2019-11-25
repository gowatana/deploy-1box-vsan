# Base vCenter Setting
$base_dc_name = "LAB-DC"
$base_cluster_name = "MGMT-Cluster"

# Base ESXi Setting
$base_hv_name = "192.168.1.20"
#$hv_user = "root"
#$hv_pass = "VMware1!"

# ESXi VM Setting
$vm_name = "vm-esxi-template-67u3"
$guest_id = "vmkernel65Guest"
$num_cpu = 2
$memory_gb = 6
$vmdk_gb = 16

$pg_name = "Nested-Trunk-Network"
$ds_name = "datastore1"
