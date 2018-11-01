$hv_name = "192.168.1.20"
$hv_user = "root"
$hv_pass = "VMware1!"

Get-Folder -Type Datacenter | New-Datacenter LAB-DC
Get-Datacenter LAB-DC | New-Cluster MGMT-Cluster
Get-Cluster MGMT-Cluster | Add-VMHost -Name $hv_name -User $hv_user -Password $hv_pass -Force
