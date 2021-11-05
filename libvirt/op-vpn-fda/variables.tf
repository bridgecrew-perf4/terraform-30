variable stack {
  type        = string
  default     = "op-vpn-fda"
}

variable status {
  type        = bool
  default     = true
}

variable addresses {
  type        = list
  default     = ["10.17.1.0/24"]
}

## Sandbox

variable sandbox_nodes {
  type        = number
  default     = 1
}

variable sandbox_nodes_disk {
  type        = number
  default     = 20 * 1024 * 1024 * 1024
}

variable sandbox_nodes_mem {
  type        = number
  default     = 2048
}
