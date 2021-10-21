resource "libvirt_cloudinit_disk" "data_nodes_init" {
    count       = var.data_nodes

    name        = "${var.stack}-data-node-${count.index}.iso"
    meta_data   = templatefile("${path.module}/meta-data.cfg",
                    {
                    hostname = "${var.stack}-data-node-${count.index}"
                    })
    user_data   = local.data_user_data
    pool        = "default"
}

resource "libvirt_volume" "data_nodes_volume" {
    count          = var.data_nodes

    name           = "${var.stack}-data-node-${count.index}.qcow2"
    pool           = "default"
    size           = var.data_nodes_disk
    base_volume_id = libvirt_volume.base-cloud.id
}

# Create a new domain
resource "libvirt_domain" "data_nodes_domain" {
    count     = var.data_nodes
        
    name      = "${var.stack}-data-node-${count.index}"
    memory    = var.data_nodes_mem
    running   = var.status

    cloudinit = libvirt_cloudinit_disk.data_nodes_init[count.index].id

    network_interface {
        network_name = "default"
        # Refactor mac generator
        mac            = "52:54:00:AA:00:B${count.index}"  
        wait_for_lease = true
    }  
    
    disk {
        volume_id = libvirt_volume.data_nodes_volume[count.index].id
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

output "data_nodes_domains" {
    value       = libvirt_domain.data_nodes_domain[*].network_interface[0].addresses[0]
}