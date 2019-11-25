# Lab Global Setting.

$base_vc_address = "192.168.1.30"
$base_vc_user = "administrator@vsphere.local"
$base_vc_pass = "VMware1!"

$nest_vc_address = "192.168.1.30"
$nest_vc_user = "administrator@vsphere.local"
$nest_vc_pass = "VMware1!"

# Base ESXi Setting
$template_vm_name = "vm-esxi-template-01"
$base_dc_name = "LAB-DC"
$base_cluster_name = "MGMT-Cluster"
$base_hv_name = "192.168.1.20"
$base_ds_name = "datastore1" # Clone Target Datastore
$base_pg_name = "Nested-Trunk-Network" # vSS-Portgroup
