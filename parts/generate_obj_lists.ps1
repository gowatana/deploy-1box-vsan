# VM / ESXi List

function gen_vm_name_list($vm_num,$hv_ip_4oct_start) {
    $hv_ip_4oct = $hv_ip_4oct_start  
    for($i=1; $i -le $vm_num; $i++){  
        $vm_name_prefix + $hv_ip_4oct.toString("000")
        $hv_ip_4oct++
    } 
}

function gen_nest_hv_hostname_list($vm_num, $hv_ip_4oct_start, $nest_hv_hostname_prefix) {   
    $hv_ip_4oct = $hv_ip_4oct_start
    for($i=1; $i -le $vm_num; $i++){      
        $nest_hv_hostname_prefix + $hv_ip_4oct.toString("00")
        $hv_ip_4oct++
    } 
}

function gen_hv_ip_vmk0_list($vm_num, $hv_ip_4oct_start, $hv_ip_prefix_vmk0) {   
    $hv_ip_4oct = $hv_ip_4oct_start
    for($i=1; $i -le $vm_num; $i++){
        $hv_ip_prefix_vmk0 + $hv_ip_4oct.ToString()
        $hv_ip_4oct++
    } 
}

$vm_name_list = gen_vm_name_list $vm_num $hv_ip_4oct_start
$nest_hv_hostname_list = gen_nest_hv_hostname_list $vm_num $hv_ip_4oct_start $nest_hv_hostname_prefix
$hv_ip_vmk0_list = gen_hv_ip_vmk0_list $vm_num $hv_ip_4oct_start $hv_ip_prefix_vmk0
$vc_hv_name_list = $hv_ip_vmk0_list
