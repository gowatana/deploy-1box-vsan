$vds_name = "lab-vds-21"

$vds_mgmt_pg_name = "dvpg_" + $vds_name + "_mgmt"
$vds_mgmt_pg_vlan = $nest_hv_vmk0_vlan
$vds_vmotion_pg_name = "dvpg_" + $vds_name + "_vmotion"
$vds_vmotion_pg_vlan = 1001
$vds_vsan_pg_name = "dvpg_" + $vds_name + "_vsan"
$vds_vsan_pg_vlan = 1002
$vds_guest_pg_name = "dvpg_" + $vds_name + "_guest"
$vds_guest_pg_vlan = 10
