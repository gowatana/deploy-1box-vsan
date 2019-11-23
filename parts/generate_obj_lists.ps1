# VM / ESXi List

$vm_name_list = $vm_num_start..$vm_num_end | % {
    $i = $_
    $vm_name_prefix + $i.toString("00")
}

$nest_hv_hostname_list = $vm_num_start..$vm_num_end | % {
    $i = $_
    $nest_hv_hostname_prefix + $i.toString("00")
}

$hv_ip_vmk0_list = $vm_num_start..$vm_num_end | % {
    $i = $_
    $hv_ip_prefix_vmk0 + ($hv_ip_4octet_base_vmk0 + $i).ToString()
}

$vc_hv_name_list = $vm_num_start..$vm_num_end | % {
    $i = $_
    $hv_ip_prefix_vmk0 + ($hv_ip_4octet_base_vmk0 + $i).ToString()
}
