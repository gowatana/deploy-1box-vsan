# set parts script directory.
$parts_path = "./parts"

# Load Functions
. "$parts_path/functions.ps1"

task_message "Step-01" "Create vSphere Cluster"
if($create_vsphre_cluster -eq $true){
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
    ./parts/step_01-1_create-vsphere-cluster.ps1
    disconnect_all_vc
}else{
    "Skip"
}

task_message "Step-02" "Setup Base-vSphere"
if($create_esxi_vms -eq $true){
    connect_vc -vc_addr $base_vc_address -vc_user $base_vc_user -vc_pass $base_vc_pass
    ./parts/step_02-1_clone-esxi-vms_for-vsan.ps1
    ./parts/step_02-2_config-esxi-guest_for-vsan.ps1
    disconnect_all_vc
}else{
    "Skip"
}

task_message "Step-03" "Setup Nested-vSphere"
if($create_vsphre_cluster -eq $true){
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
    ./parts/step_03-1_setup-vsphere-cluster.ps1
    ./parts/step_03-2_create-vmk-port_on-vss.ps1
    disconnect_all_vc
}else{
    "Skip"
}

task_message "Step-04" "Setup vDS"
if($create_vds -eq $true){
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
    ./parts/step_04-1_create-vds.ps1
    disconnect_all_vc
}else{
    "Skip"
}

task_message "Step-05" "Setup Witness-Host VA"
if($create_witness_vm -eq $true){
    connect_vc -vc_addr $base_vc_address -vc_user $base_vc_user -vc_pass $base_vc_pass
    ./parts/step_05-1_clone-vSAN-Witness-VA.ps1
    ./parts/step_05-2_config-vSAN-Witness-VA-Guest.ps1
    disconnect_all_vc
}else{
    "Skip"
}

task_message "Step-06" "Setup Witness-Host on vCenter"
if($create_witness_vm -eq $true){
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
    ./parts/step_06-1_add-vSAN-Witness-Host.ps1
    disconnect_all_vc
}else{
    "Skip"
}

task_message "Step-07" "Setup Data-Host for vSAN WTS"
if($setup_vsan_wts -eq $true){
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
    ./parts/step_07-1_setup-vsan-witness-nw.ps1
    disconnect_all_vc
}else{
    "Skip"
}

task_message "Step-08" "Setup vSAN Cluster"
if($create_vsan_cluster -eq $true){
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
    ./parts/step_08-1_setup-vsan-disk.ps1
    ./parts/step_08-2_setup-vsan-cluster.ps1
    disconnect_all_vc
}else{
    "Skip"
}

task_message "Step-09" "Add VMDK for vSAN Disk Group"
if($vsan_dg_count -ge 2){
    connect_vc -vc_addr $base_vc_address -vc_user $base_vc_user -vc_pass $base_vc_pass
    for($i=2; $i -le $vsan_dg_count; $i++){
        ./parts/step_09-1_add-vsan-vmdk.ps1
    }
    disconnect_all_vc
}else{
    "Skip"
}

task_message "Step-10" "Add vSAN Disk Group"
if($vsan_dg_count -ge 2){
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
    for($i=2; $i -le $vsan_dg_count; $i++){
        ./parts/step_10-1_fix-disk-type.ps1
        ./parts/step_10-2_add-vsan-dg.ps1
    }
    disconnect_all_vc
}else{
    "Skip"
}

task_message "Step-11" "Setup 2-Node vSAN"
if($create_vsan_2node -eq $true){
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
    ./parts/step_11-1_create-vSAN-Cluster-2Node.ps1
    disconnect_all_vc
}else{
    "Skip"
}

task_message "Step-20" "vSAN Cluster Health Check"
if($create_vsan_cluster -eq $true){
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
    ./parts/step_20-1_test-vsan-cluster.ps1
    disconnect_all_vc
}else{
    "Skip"
}
