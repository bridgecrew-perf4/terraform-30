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

resource "time_sleep" "data_wait_15_seconds" {
  depends_on = [libvirt_domain.data_nodes_domain]

  create_duration = "15s"
}

resource "null_resource" "data_copy-elasticsearch" {
    count     = var.data_nodes
    depends_on = [time_sleep.data_wait_15_seconds]

    connection {
        type     = "ssh"
        host     = libvirt_domain.data_nodes_domain[count.index].network_interface[0].addresses[0]
        user     = "elastic"
        agent    =  false
        private_key = file("~/.ssh/id_rsa")
    }
    

    provisioner "file" {
        content      = templatefile("${path.module}/elasticsearch.tpl",
                        {
                        cluster_name = "cluster",
                        cluster_initial_master_nodes = "${var.stack}-data-node-0",
                        bootstrap_memory_lock = false,
                        discovery_seed_hosts = libvirt_domain.master_nodes_domain[*].network_interface[0].addresses[0],
                        node_data = true,
                        node_master = false,
                        node_ingest = false,
                        hostname = "${var.stack}-data-node-${count.index}"
                        })
        destination = "/etc/elasticsearch/elasticsearch.yml"
    }
}

resource "null_resource" "data_copy-jvm-options" {
    count     = var.data_nodes
    depends_on = [time_sleep.data_wait_15_seconds]

    connection {
        type     = "ssh"
        host     = libvirt_domain.data_nodes_domain[count.index].network_interface[0].addresses[0]
        user     = "elastic"
        agent    =  false
        private_key = file("~/.ssh/id_rsa")
    }
    

    provisioner "file" {

        content      = templatefile("${path.module}/jvm.options",
                        {
                        heap_mem = var.data_heap_mem
                        })        

        destination = "/etc/elasticsearch/jvm.options"
    }
}

resource "null_resource" "data_copy-log4j2-properties" {
    count     = var.data_nodes
    depends_on = [time_sleep.data_wait_15_seconds]

    connection {
        type     = "ssh"
        host     = libvirt_domain.data_nodes_domain[count.index].network_interface[0].addresses[0]
        user     = "elastic"
        agent    =  false
        private_key = file("~/.ssh/id_rsa")
    }
    

    provisioner "file" {

        source = "${path.module}/log4j2.properties"
        destination = "/etc/elasticsearch/log4j2.properties"
    }
}

output "data_nodes_domains" {
    value       = libvirt_domain.data_nodes_domain[*].network_interface[0].addresses[0]
}