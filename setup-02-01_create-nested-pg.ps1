$hv_name = "192.168.1.20"
$pg_name = "Nested-Trunk-Network"

$pg = Get-VMHost $hv_name | Get-VirtualSwitch -Name vSwitch0 |
    New-VirtualPortGroup -Name $pg_name -VLanId 4095
$pg | Get-SecurityPolicy |
    Set-SecurityPolicy -AllowPromiscuous:$true -ForgedTransmits:$true -MacChanges:$true