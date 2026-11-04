module "resource_group" {
  source = "./modules/resource-group"

  resource_group_name = var.resource_group_name
  location            = var.location
}

module "storage" {
  source = "./modules/storage"

  storage_account_name = var.storage_account_name
  resource_group_name  = module.resource_group.rg_name
  location             = var.location
}

module "virtual_machines" {
  source = "./modules/virtual-machines"

  resource_group_name = var.resource_group_name
  storage_account_name = var.storage_account_name

  admin_username = var.admin_username
  admin_password = var.admin_password

  depends_on = [
    module.storage
  ]
}