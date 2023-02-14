variable "location" {
  description = "Azure location for deployment"
  default     = "East US"
}

variable "rg_name" {
  type        = string
  description = "Name of an Resource Group"
}

variable "appgw_name" {
  description = "Name of an Application Gateway Resource."
}

# SKU Configuration
variable "sku_name" {
  description = "Name of App Gateway SKU."
  default     = "WAF_v2"
}
variable "sku_tier" {
  description = "Tier of App Gateway SKU."
  default     = "WAF_v2"
}

# Capacity of an application gateway for V2 SKU.
variable "capacity_min" {
  description = "Minimum capacity of App Gateway"
}
variable "capacity_max" {
  description = "Maximum capacity of App Gateway"
}

# Subnet for application gateway deployment.
variable "app_gw_subnet_id" {
  description = "Subnet in which Application Gateway resource will be deployed"
}

variable "private_ip_address" {
  description = "Private IP Address to assign to the application gateway"
}

# Backend pool association configuration
variable "backend_address_pools" {
  description = "List of backend address pools."
  type = list(object({
    name         = string
    ip_addresses = list(string)
    fqdns        = list(string)
  }))
}

# Backend HTTP Settings 
variable "backend_http_settings" {
  description = "List of backend HTTP settings."
  type = list(object({
    name            = string
    path            = string
    is_https        = bool
    request_timeout = string
  }))
}

# Listener Configuration
variable "http_listeners" {
  description = "List of HTTP/HTTPS listeners. HTTPS listeners require an SSL Certificate object."
  type = list(object({
    name                 = string
    ssl_certificate_name = string
  }))
}

# Basic Request routing rules
variable "basic_request_routing_rules" {
  description = "Request routing rules to be used for listeners."
  type = list(object({
    name                       = string
    http_listener_name         = string
    backend_address_pool_name  = string
    backend_http_settings_name = string
    priority                   = string
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}