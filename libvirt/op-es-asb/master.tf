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

    name           = "${var.stack}-master-node-${count.index}.qcow2"
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

output "master_nodes_domains" {
    value       = libvirt_domain.master_nodes_domain[*].network_interface[0].addresses[0]
}