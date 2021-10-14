terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.11"
    }
  }
}

# Configure the Libvirt provider
provider "libvirt" {
  uri = "qemu:///system"
}

variable stack {
  type        = string
  default     = "op-es"
}

variable servers {
  type        = number
  default     = 3
}

variable status {
  type        = bool
  default     = true
}

# Create Cloud-Init

# data "template_file" "meta_data" {
#   template = file("${path.module}/meta-data.cfg")
# }

data "template_file" "user_data" {
  template = file("${path.module}/user-data.yaml")
}

resource "libvirt_cloudinit_disk" "server-ci" {
  name           = "${var.stack}-server-ci.iso"
#   meta_data = data.template_file.meta_data.rendered  
  user_data      = data.template_file.user_data.rendered
  pool           = "default"
}

# Create Volume

resource "libvirt_volume" "base-cloud" {
  name   = "${var.stack}-base-cloud.img"
  pool   = "default"
  format = "qcow2"
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
}

resource "libvirt_volume" "server-volume" {
    count          = var.servers

    name           = "${var.stack}-${count.index}.qcow2"
    pool           = "default"
    size           = 21474836480 # 20G
    base_volume_id = libvirt_volume.base-cloud.id
}

# Create a new domain
resource "libvirt_domain" "server-domains" {
    count     = var.servers
        
    name      = "${var.stack}-${count.index}"
    memory    = 4096
    running   = var.status

    cloudinit = libvirt_cloudinit_disk.server-ci.id

    network_interface {
        network_name = "default"
    }  
    
    disk {
        volume_id = libvirt_volume.server-volume[count.index].id
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

output "server-domains" {
    value       = libvirt_domain.server-domains[*].network_interface[0].addresses[0]
}