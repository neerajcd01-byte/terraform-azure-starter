output "resource_group" {
  value = module.resource_group.rg_name
}

output "storage_account" {
  value = module.storage.storage_account_name
}
