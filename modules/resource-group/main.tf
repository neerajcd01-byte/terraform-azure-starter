resource "azurerm_resource_group" "github-test" {
  name     = var.resource_group_name
  location = var.location
}