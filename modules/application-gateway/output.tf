output "application_gateway_public_ip" {
  value = azurerm_public_ip.appgw_pip.ip_address
}

output "application_gateway_id" {
  value = azurerm_application_gateway.appgw.id
}