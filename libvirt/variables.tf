variable stack {
  type        = string
  default     = "op-es"
}

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
  default     = 512
}

variable status {
  type        = bool
  default     = true
}

variable es_version {
  type        = string
  default     = "7.15.1"
}
