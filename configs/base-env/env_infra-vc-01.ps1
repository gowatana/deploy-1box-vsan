# Lab Base environment Config file

# Base vCenter Login info
$base_vc_address = "infra-vc-01.go-lab.jp"
$base_vc_user = "automation@go-lab.jp"
$base_vc_pass = "VMware1!"

# Nested vCenter Login info
$nest_vc_address = $base_vc_address
$nest_vc_user = $base_vc_user
$nest_vc_pass = $base_vc_pass

# Base ESXi info
$base_dc_name = "infra-dc-01"
$base_cluster_name = "infra-cluster-01"
$base_hv_name = "infra-esxi-05.go-lab.jp"
$base_ds_name = "vsanDatastore" # Clone Target Datastore
$base_pg_name = "dvpg-nested-trunk"
