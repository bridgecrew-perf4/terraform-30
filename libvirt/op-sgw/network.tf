resource "libvirt_network" "sandbox_network" {
    name = "${var.stack}"
    mode      = "nat"
    domain    = "${var.stack}.local"
    autostart = true
    addresses = var.addresses
    dhcp {
        enabled = true
    }
    dns {
        enabled = true
    }
}