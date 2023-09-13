variable name_rg {
  type        = string
  description = "Resource Group Name"
}

variable location {
  type        = string
  default     = "West Europe"
  description = "Location"
}

variable name_vn {
  type        = string
  description = "Virtual Network Name"
}

variable config_vn_as {
  type        = string
  description = "Virtual Network Address Space"
}

variable name_sn {
  type        = string
  description = "Subnate Name"
}

variable config_sn_ap {
  type        = string
  description = "Subnate Address Space"
}

variable name_ni {
  type        = string
  description = "Network Interface Name"
}

variable name_ni_ic {
  type        = string
  description = "Network Interface Ip Configuration Name"
}

variable name_pi {
  type        = string
  description = "Public Ip Name"
}

variable name_vm {
  type        = string
  description = "Virtual Machine Name"
}

variable name_vm_os {
  type        = string
  description = "Virtual Machine OS Disk Name"
}

variable name_nsg {
  type        = string
  description = "Network Security Group Name"
}