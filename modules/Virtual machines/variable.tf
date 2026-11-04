variable "resource_group_name" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}