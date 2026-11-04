output "resource_group" {
  value = module.resource_group.rg_name
}

output "storage_account" {
  value = module.storage.storage_account_name
}

output "app_gateway_public_ip" {
  value = module.application_gateway.application_gateway_public_ip
}