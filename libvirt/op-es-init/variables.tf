variable stack {
  type        = string
  default     = "op-es"
}

variable status {
  type        = bool
  default     = true
}

variable es_version {
  type        = string
  default     = "7.15.1"
}

## Master Nodes

variable master_nodes {
  type        = number
  default     = 3
}

variable master_nodes_disk {
  type        = number
  default     = 10 * 1024 * 1024 * 1024
}

variable master_nodes_mem {
  type        = number
  default     = 2048
}

variable master_heap_mem {
  type        = string
  default     = "512m"
}

## Data Nodes

variable data_nodes {
  type        = number
  default     = 3
}

variable data_nodes_disk {
  type        = number
  default     = 10 * 1024 * 1024 * 1024
}

variable data_nodes_mem {
  type        = number
  default     = 2048
}

variable data_heap_mem {
  type        = string
  default     = "1024m"
}

## Ingest Nodes

variable ingest_nodes {
  type        = number
  default     = 2
}

variable ingest_nodes_disk {
  type        = number
  default     = 10 * 1024 * 1024 * 1024
}

variable ingest_nodes_mem {
  type        = number
  default     = 2048
}

variable ingest_heap_mem {
  type        = string
  default     = "512m"
}