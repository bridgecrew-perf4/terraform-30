variable stack {
  type        = string
  default     = "op-vpn-gc"
}

variable status {
  type        = bool
  default     = true
}

## Master Nodes

variable master_nodes {
  type        = number
  default     = 1
}

variable master_nodes_disk {
  type        = number
  default     = 10 * 1024 * 1024 * 1024
}

variable master_nodes_mem {
  type        = number
  default     = 512
}
