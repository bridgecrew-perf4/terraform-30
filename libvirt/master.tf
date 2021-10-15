resource "libvirt_cloudinit_disk" "master_nodes_init" {
    count       = var.master_nodes

    name        = "${var.stack}-master-node-${count.index}.iso"
    meta_data   = templatefile("${path.module}/meta-data.cfg",
                    {
                    hostname = "${var.stack}-master-node-${count.index}"
                    })
    user_data   = local.master_user_data
    pool        = "default"
}

resource "libvirt_volume" "master_nodes_volume" {
    count          = var.master_nodes

    name           = "${var.stack}-${count.index}.qcow2"
    pool           = "default"
    size           = var.master_nodes_disk
    base_volume_id = libvirt_volume.base-cloud.id
}

# Create a new domain
resource "libvirt_domain" "master_nodes_domain" {
    count     = var.master_nodes
        
    name      = "${var.stack}-master-node-${count.index}"
    memory    = var.master_nodes_mem
    running   = var.status

    cloudinit = libvirt_cloudinit_disk.master_nodes_init[count.index].id

    network_interface {
        network_name = "default"
        wait_for_lease = true
    }  
    
    disk {
        volume_id = libvirt_volume.master_nodes_volume[count.index].id
    }

    console {
        type        = "pty"
        target_port = "0"
        target_type = "serial"
    }

    console {
        type        = "pty"
        target_type = "virtio"
        target_port = "1"
    }

    graphics {
        type        = "spice"
        listen_type = "address"
        autoport    = true
    }

}

resource "null_resource" "copy-config" {
    count     = var.master_nodes

    connection {
        type     = "ssh"
        host     = libvirt_domain.master_nodes_domain[count.index].network_interface[0].addresses[0]
        user     = "luciano"
        agent    =  false
        private_key = file("~/.ssh/id_rsa")
    }
    

    provisioner "file" {
        content      = templatefile("${path.module}/elasticsearch.yml",
                        {
                        cluster_name = "cluster",
                        cluster_initial_master_nodes = "${var.stack}-master-node-0",
                        bootstrap_memory_lock = false,
                        # Need a list
                        discovery_seed_hosts = libvirt_domain.master_nodes_domain[0].network_interface[0].addresses[0],
                        node_data = false,
                        node_master = true,
                        hostname = "${var.stack}-master-node-${count.index}"
                        })
        # Create a new folder with the with perms                        
        destination = "~/elasticsearch.yml"
    }

}