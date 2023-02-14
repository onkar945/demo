# Public ip address of an Application Gateway.
output "ip_address" {
  description = "Public IP Address of App Gateway."
  value       = azurerm_public_ip.appgwpip.ip_address
}

output "application_gateway_id" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.app-gateway.id
}