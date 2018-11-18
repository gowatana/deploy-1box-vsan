# Load Config file.
$config_file_name = $args[0]
. $config_file_name
if($? -eq $false){"config file not found."; exit}

$pg = Get-VMHost $hv_name | Get-VirtualSwitch -Name vSwitch0 |
    New-VirtualPortGroup -Name $pg_name -VLanId 4095
$pg | Get-SecurityPolicy |
    Set-SecurityPolicy -AllowPromiscuous:$true -ForgedTransmits:$true -MacChanges:$true