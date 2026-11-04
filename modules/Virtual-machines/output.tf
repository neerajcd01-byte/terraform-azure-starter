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