$vm_name_list | ForEach-Object {
    $vm_name = $_
    $vm = Get-Datacenter $base_dc_name | Get-Cluster $base_cluster_name | Get-VM $vm_name
    
    task_message "09-01-01" ("Add VMDK (Cache device): " + $vm_name)
    $vm | New-HardDisk -SizeGB $vsan_cache_disk_size_gb -StorageFormat Thin |
        select Parent,Name,CapacityGB | ft -AutoSize
    
    task_message "09-01-02" ("Add VMDK (Capacity device): " + $vm_name)
    for($i=1; $i -le $vsan_capacity_disk_count; $i++){
        $vm | New-HardDisk -SizeGB $vsan_capacity_disk_size_gb -StorageFormat Thin |
            select Parent,Name,CapacityGB | ft -AutoSize
    }
}
