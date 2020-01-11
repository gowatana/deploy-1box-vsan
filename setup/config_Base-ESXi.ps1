# Base vSphere config file

# Base vSphere Setting
$base_dc_name = "LAB-DC"
$base_cluster_name = "MGMT-Cluster"
$base_pg_name = "Nested-Trunk-Network"
$base_ds_name = "datastore1"

# Base ESXi Setting: Used only when registering to vCenter.
$base_hv_name = "192.168.1.20"
$base_hv_user = "root"
$base_hv_pass = "VMware1!"

# Nested ESXi VM Setting
$vm_name = "vm-esxi-template-67u3"
$guest_id = "vmkernel65Guest"
$num_cpu = 2
$memory_gb = 6
$vmdk_gb = 16
