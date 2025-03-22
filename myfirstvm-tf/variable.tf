variable location {
  type        = string
  description = "Location for the Azure resources"
}

variable subscription_id {
  type        = string
  description = "Subscription ID for the Azure account"
}

variable resource_group_name {
  type        = string
  description = "Name of the resource group"
}

variable virtual_network_name {
  type        = string
  description = "Name of the virtual network"
}

variable subnet_name {
  type        = string
  description = "Name of the subnet"
}

variable network_interface_name {
  type        = string
  description = "Name of the network interface"
}

variable linux_virtual_machine_name {
  type        = string
  description = "Name of the Linux virtual machine"
}

variable network_security_group_name {
  type        = string
  description = "Name of the network security group"
}

variable public_ip_name {
  type        = string
  description = "Name of the public IP address"
}