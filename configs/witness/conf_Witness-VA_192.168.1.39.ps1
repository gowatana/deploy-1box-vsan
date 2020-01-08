# vSAN-Lab Config file

$create_witness_vm = $true

# Base-vSphere environment config
. ./configs/base-env/env_home-lab-01.ps1

$hv_user = "root"
$hv_pass = "VMware1!"

# Witness VA Base Config
$base_witness_pg_name_1 = ""
$base_witness_pg_name_2 = ""

# Witness Host Config
$witness_dc = "LAB-DC"
$witness_host_folder = "Witness-Hosts" # if "host", it is added to DC
$vsan_witness_host_name = "esxi-039"
$vsan_witness_host_domain = "go-lab.jp"
$vsan_witness_host_ip = "192.168.1.39"
$vsan_witness_host_subnetmask = "255.255.255.0"
$vsan_witness_host_gw = "192.168.1.1"
$vsan_witness_dns_1 = "192.168.1.101"
$vsan_witness_dns_2 = "192.168.1.102"
$vsan_witness_host_vcname = $vsan_witness_host_ip
$vsan_wts = $true # $true or $false
$vsan_witness_template_name = "VMware-VirtualSAN-Witness-6.7.0.update03-14320388"
$vsan_witness_va_name = "vm-esxi-witness-" + $vsan_witness_host_ip
