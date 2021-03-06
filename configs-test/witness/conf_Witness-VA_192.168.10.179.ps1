# Witness Host ESXi Login
$vsan_witness_host_user = $hv_user
$vsan_witness_host_pass = $hv_pass

# Witness Host Config
$witness_dc = "lab-witness-dc-01"
$witness_host_folder = "Witness-Hosts" # if "host", it is added to DC
$vsan_witness_host_name = "esxi-179"
$vsan_witness_host_domain = "go-lab.jp"
$vsan_witness_host_ip = "192.168.10.179"
$vsan_witness_host_vlan = $nest_hv_vmk0_vlan
$vsan_witness_host_subnetmask = "255.255.255.0"
$vsan_witness_host_gw = "192.168.10.1"
$vsan_witness_host_vcname = $vsan_witness_host_ip
$vsan_witness_host_dns_servers = $dns_servers
$vsan_witness_host_ntp_servers = $ntp_servers

# Witness VA Base Config
$vsan_witness_template_name = "VMware-VirtualSAN-Witness-7.0U1-16850804"
$vsan_witness_va_name = "vm-esxi-witness-" + $vsan_witness_host_ip

$base_witness_pg_name_1 = $base_pg_name
$base_witness_pg_name_2 = $base_pg_name
