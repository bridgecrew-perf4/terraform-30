locals {
  sandbox_user_data = templatefile("${path.module}/user-data.yaml",{})
}

resource "libvirt_cloudinit_disk" "sandbox_nodes_init" {
    count       = var.sandbox_nodes

    name        = "${var.stack}-sandbox-node-${count.index}.iso"
    meta_data   = templatefile("${path.module}/meta-data.cfg",
                    {
                    hostname = "${var.stack}-sandbox-node-${count.index}"
                    })
    user_data   = local.sandbox_user_data
    pool        = "default"
}

resource "libvirt_volume" "sandbox_nodes_volume" {
    count          = var.sandbox_nodes

    name           = "${var.stack}-sandbox-node-${count.index}.qcow2"
    pool           = "default"
    size           = var.sandbox_nodes_disk
    base_volume_id = libvirt_volume.base-cloud.id
}

# Create a new domain
resource "libvirt_domain" "sandbox_nodes_domain" {
    count     = var.sandbox_nodes
        
    name      = "${var.stack}-sandbox-node-${count.index}"
    memory    = var.sandbox_nodes_mem
    vcpu      = var.sandbox_nodes_vcpu
    running   = var.status

    cloudinit = libvirt_cloudinit_disk.sandbox_nodes_init[count.index].id

    network_interface {
        network_name = libvirt_network.sandbox_network.name
        mac            = "52:54:00:92:6c:de"
        wait_for_lease = true
    }  
    
    disk {
        volume_id = libvirt_volume.sandbox_nodes_volume[count.index].id
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

    video {
        type = "qxl"
    }

    xml {
        xslt = file("./add_spicevmc.xsl")
    }

}

output "sandbox_nodes_domains" {
    value       = libvirt_domain.sandbox_nodes_domain[*].network_interface[0].addresses[0]
}