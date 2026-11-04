#######################################
# Existing Resource Group
#######################################

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

#######################################
# Existing Storage Account
#######################################

data "azurerm_storage_account" "sa" {
  name                = var.storage_account_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

#######################################
# Virtual Network
#######################################

resource "azurerm_virtual_network" "vnet" {
  name                = "vm-vnet"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  address_space = ["10.0.0.0/16"]
}

#######################################
# Subnet
#######################################

resource "azurerm_subnet" "subnet" {
  name                 = "vm-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = ["10.0.1.0/24"]
}

#######################################
# NSG
#######################################

resource "azurerm_network_security_group" "nsg" {
  name                = "vm-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

#######################################
# SSH Rule
#######################################

resource "azurerm_network_security_rule" "ssh" {
  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"

  source_port_range           = "*"
  destination_port_range      = "22"

  source_address_prefix       = "*"
  destination_address_prefix  = "*"

  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

#######################################
# RDP Rule
#######################################

resource "azurerm_network_security_rule" "rdp" {
  name                        = "AllowRDP"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"

  source_port_range           = "*"
  destination_port_range      = "3389"

  source_address_prefix       = "*"
  destination_address_prefix  = "*"

  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

#######################################
# Linux Public IP
#######################################

resource "azurerm_public_ip" "linux_pip" {
  name                = "linux-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  allocation_method = "Static"
  sku               = "Standard"
}

#######################################
# Windows Public IP
#######################################

resource "azurerm_public_ip" "windows_pip" {
  name                = "windows-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  allocation_method = "Static"
  sku               = "Standard"
}

#######################################
# Linux NIC
#######################################

resource "azurerm_network_interface" "linux_nic" {
  name                = "linux-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "linux-ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux_pip.id
  }
}

#######################################
# Windows NIC
#######################################

resource "azurerm_network_interface" "windows_nic" {
  name                = "windows-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "windows-ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows_pip.id
  }
}

#######################################
# NSG Association Linux
#######################################

resource "azurerm_network_interface_security_group_association" "linux_assoc" {
  network_interface_id      = azurerm_network_interface.linux_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

#######################################
# NSG Association Windows
#######################################

resource "azurerm_network_interface_security_group_association" "windows_assoc" {
  network_interface_id      = azurerm_network_interface.windows_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

#######################################
# Linux VM
#######################################

resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                = "ubuntu-vm"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  size = "Standard_B2s"

  admin_username = var.admin_username
  admin_password = var.admin_password

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.linux_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.sa.primary_blob_endpoint
  }
}

#######################################
# Windows VM
#######################################

resource "azurerm_windows_virtual_machine" "windows_vm" {
  name                = "windows-vm"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  size = "Standard_B2s"

  admin_username = var.admin_username
  admin_password = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.windows_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.sa.primary_blob_endpoint
  }
}