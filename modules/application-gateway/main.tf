resource "azurerm_public_ip" "appgw_pip" {
  name                = "appgw-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_application_gateway" "appgw" {

  name                = "appgw-dev"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name         = "backendpool"
    ip_addresses = [var.backend_ip_address]
  }

  backend_http_settings {
    name                  = "httpsettings"
    cookie_based_affinity = "Disabled"

    port     = 80
    protocol = "Http"

    request_timeout = 30
  }

  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"

    http_listener_name         = "listener"

    backend_address_pool_name  = "backendpool"

    backend_http_settings_name = "httpsettings"

    priority = 100
  }
}