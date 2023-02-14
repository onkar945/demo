#---------------------------
# Local declarations
#---------------------------
locals {
  appgwpip_name                          = "${var.appgw_name}-pip"
  frontend_port_name                     = "${var.appgw_name}-feport"
  frontend_public_ip_configuration_name  = "${var.appgw_name}-public-feip"
  frontend_private_ip_configuration_name = "${var.appgw_name}-private-feip"
  gateway_ip_configuration_name          = "${var.appgw_name}-gwipc"
}

#---------------------------------------------------------------
# Create a public ip for frontend_ip_configuration of appgateway
#---------------------------------------------------------------
resource "azurerm_public_ip" "appgwpip" {
  name                = local.appgwpip_name
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = merge({ "Name" = format("%s", local.appgwpip_name) }, var.tags, )
}

#-----------------------------
# Create a application gateway
#-----------------------------
resource "azurerm_application_gateway" "app-gateway" {
  name                = var.appgw_name
  resource_group_name = var.rg_name
  location            = var.location
  tags                = merge({ "Name" = format("%s", var.appgw_name) }, var.tags, )

  # Sku Configuration
  sku {
    name = var.sku_name
    tier = var.sku_tier
  }

  # Autoscale configuration (Only available in V2 SKU)
  autoscale_configuration {
    min_capacity = var.capacity_min
    max_capacity = var.capacity_max
  }

  # Gateway configuration and specify subnet for app gateway deployment.
  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = var.app_gw_subnet_id
  }

  # Frontend port
  frontend_port {
    name = "${local.frontend_port_name}-https"
    port = 443
  }

  frontend_port {
    name = "${local.frontend_port_name}-http"
    port = 80
  }

  # Frontend configuration for Public Endpoint
  frontend_ip_configuration {
    name                 = local.frontend_public_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgwpip.id
  }

  # Frontend configuration for Private Endpoint
  frontend_ip_configuration {
    name                          = local.frontend_private_ip_configuration_name
    private_ip_address            = var.private_ip_address
    private_ip_address_allocation = "Static"
    subnet_id                     = var.app_gw_subnet_id
  }

  # Backend address pool configuration 
  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name         = backend_address_pool.value.name
      ip_addresses = backend_address_pool.value.ip_addresses
      fqdns        = backend_address_pool.value.fqdns
    }
  }

  # Backend HTTP Settings 
  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                  = backend_http_settings.value.name
      cookie_based_affinity = "Disabled"
      path                  = backend_http_settings.value.path
      port                  = backend_http_settings.value.is_https ? "443" : "80"
      protocol              = backend_http_settings.value.is_https ? "Https" : "Http"
      request_timeout       = backend_http_settings.value.request_timeout
    }
  }

  # Listener Configuration
  dynamic "http_listener" {
    for_each = var.http_listeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = local.frontend_public_ip_configuration_name
      frontend_port_name             = http_listener.value.ssl_certificate_name != null ? "${local.frontend_port_name}-https" : "${local.frontend_port_name}-http"
      protocol                       = http_listener.value.ssl_certificate_name != null ? "Https" : "Http"
      ssl_certificate_name           = http_listener.value.ssl_certificate_name
    }
  }

  # Basic Rules
  dynamic "request_routing_rule" {
    for_each = var.basic_request_routing_rules
    content {
      name                       = request_routing_rule.value.name
      rule_type                  = "Basic"
      http_listener_name         = request_routing_rule.value.http_listener_name
      backend_address_pool_name  = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
      priority                   = request_routing_rule.value.priority
    }
  }

  # WAF Configuration
  waf_configuration {
    enabled          = true
    firewall_mode    = "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = 3.1
  }

  depends_on = [
    azurerm_public_ip.appgwpip
  ]
}