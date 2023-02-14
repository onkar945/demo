variable "location" {
  description = "Azure location for deployment"
  default     = "East US"
}

variable "rg_name" {
  type        = string
  description = "Name of an Resource Group"
}

variable "kv_name" {
  type        = string
  description = "Name of Azure Key Vault"
}

variable "access_policies" {
  description = "A list of up to 16 objects describing access policies"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}