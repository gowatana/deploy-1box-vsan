# vSAN-Lab Config file

# Base-vSphere environment config
$config_base = Split-Path -Path $PSScriptRoot -Parent
$env_config = "$config_base/base-env/env_lab-vc-01.ps1"
Get-Item $env_config -ErrorAction:Stop | fl FullName,LastWriteTime
. $env_config

$vsan_witness_host_user = $hv_user
$vsan_witness_host_pass = $hv_pass

# Witness Host Config
$witness_dc = "lab-witness-dc-01"
$witness_host_folder = "Witness-Hosts" # if "host", it is added to DC
$vsan_witness_host_name = "vsan70u1-esxi-w-139"
$vsan_witness_host_domain = "go-lab.jp"
$vsan_witness_host_ip = "192.168.10.139"
$vsan_witness_host_vlan = $nest_hv_vmk0_vlan
$vsan_witness_host_subnetmask = "255.255.255.0"
$vsan_witness_host_gw = "192.168.10.1"
$vsan_witness_host_vcname = $vsan_witness_host_ip
$vsan_witness_host_dns_servers = $dns_servers
$vsan_witness_host_ntp_servers = $ntp_servers

# Witness VA Base Config
$vsan_witness_template_name = "VMware-VirtualSAN-Witness-7.0U1-16850804"
$vsan_witness_va_name = "vm-vsan70u1-witness-" + $vsan_witness_host_ip

$base_witness_pg_name_1 = $base_pg_name
$base_witness_pg_name_2 = $base_pg_name
