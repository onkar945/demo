variable "rg_name" {
  type        = string
  description = "Azure Resource group for resource deployment"
}

variable "location" {
  description = "Azure location for deployment"
  default     = "East US"
}

variable "vnet_name" {
  description = "Name of your Azure Virtual Network"
}

variable "vnet_address_space" {
  description = "The address space to be used for the Azure virtual network."
}

variable "subnets" {
  description = "For each subnet, create an object that contain fields"
  default     = {}
}

variable "gateway_subnet_address_prefix" {
  description = "The address prefix to use for the gateway subnet"
  default     = null
}

variable "dns_servers" {
  description = "List of dns servers to use for virtual network"
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}