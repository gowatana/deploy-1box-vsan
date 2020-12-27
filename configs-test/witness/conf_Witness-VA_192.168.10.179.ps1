# vSAN-Lab Config file

# Base-vSphere environment config
$config_base = Split-Path -Path $PSScriptRoot -Parent
$env_config = "$config_base/base-env/env_lab-vc-01.ps1"
Get-Item $env_config -ErrorAction:Stop | fl FullName,LastWriteTime
. $env_config

$hv_user = "root"
$hv_pass = "VMware1!"

# Witness VA Base Config
$base_witness_pg_name_1 = "Nested-Trunk-Network"
$base_witness_pg_name_2 = "Nested-Trunk-Network"

# Witness Host Config
$witness_dc = "LAB-DC"
$witness_host_folder = "Witness-Hosts" # if "host", it is added to DC
$vsan_witness_host_name = "esxi-038"
$vsan_witness_host_domain = "go-lab.jp"
$vsan_witness_host_ip = "192.168.10.179"
$vsan_witness_host_subnetmask = "255.255.255.0"
$vsan_witness_host_gw = "192.168.10.1"
$vsan_witness_dns_1 = "192.168.1.101"
$vsan_witness_dns_2 = "192.168.1.102"
$vsan_witness_host_vcname = $vsan_witness_host_ip

$vsan_wts = $false # Witness Traffic Separation (WTS): $true or $false
$vsan_witness_template_name = "VMware-VirtualSAN-Witness-6.7.0.update03-14320388"
$vsan_witness_va_name = "vm-esxi-witness-" + $vsan_witness_host_ip