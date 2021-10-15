terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.11"
    }
    # cloudinit = {
    #   source = "hashicorp/cloudinit"
    #   version = "2.2.0"
    # }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "base-cloud" {
  name   = "${var.stack}-base-cloud.img"
  pool   = "default"
  format = "qcow2"
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
}