output "master_nodes_domains" {
    value       = libvirt_domain.master_nodes_domain[*].network_interface[0].addresses[0]
}
