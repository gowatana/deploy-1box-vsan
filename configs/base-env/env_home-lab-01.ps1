# Lab Base environment Config file

# Base vCenter Login info
$base_vc_address = "192.168.1.30"
$base_vc_user = "administrator@vsphere.local"
$base_vc_pass = "VMware1!"

# Nested vCenter Login info
$nest_vc_address = $base_vc_address
$nest_vc_user = $base_vc_user
$nest_vc_pass = $base_vc_pass

# Base ESXi info
$base_dc_name = "LAB-DC"
$base_cluster_name = "MGMT-Cluster"
$base_hv_name = "192.168.1.20"
$base_ds_name = "datastore1" # Clone Target Datastore
$base_pg_name = "Nested-Trunk-Network" # vSS-Portgroup
