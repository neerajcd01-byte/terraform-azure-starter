output "linux_vm_public_ip" {
  value = azurerm_public_ip.linux_pip.ip_address
}

output "windows_vm_public_ip" {
  value = azurerm_public_ip.windows_pip.ip_address
}

output "linux_vm_name" {
  value = azurerm_linux_virtual_machine.linux_vm.name
}

output "windows_vm_name" {
  value = azurerm_windows_virtual_machine.windows_vm.name
}

output "linux_private_ip" {
  value = azurerm_network_interface.linux_nic.private_ip_address
}

output "subnet_id" {
  value = azurerm_subnet.subnet.id
}

output "location" {
  value = data.azurerm_resource_group.rg.location
}

output "appgw_subnet_id" {
  value = azurerm_subnet.appgw_subnet.id
}