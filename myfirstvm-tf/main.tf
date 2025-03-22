#declare the provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "linuxvmrg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "linuxvmvnet" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.linuxvmrg.location
  resource_group_name = azurerm_resource_group.linuxvmrg.name
}

resource "azurerm_subnet" "vmsubnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.linuxvmrg.name
  virtual_network_name = azurerm_virtual_network.linuxvmvnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "vmnic" {
  name                = var.network_interface_name
  location            = azurerm_resource_group.linuxvmrg.location
  resource_group_name = azurerm_resource_group.linuxvmrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vmsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linuxvmpublicip.id
  }
}

resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                = var.linux_virtual_machine_name
  resource_group_name = azurerm_resource_group.linuxvmrg.name
  location            = azurerm_resource_group.linuxvmrg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "Password*#123"
  network_interface_ids = [
    azurerm_network_interface.vmnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  disable_password_authentication = false
  provision_vm_agent              = true
}

#subnet_ network_interface_ linux_virtual_machine to get a public ip address

resource "azurerm_network_security_group" "linuxvmnsg" {
  name                = var.network_security_group_name
  location            = azurerm_resource_group.linuxvmrg.location
  resource_group_name = azurerm_resource_group.linuxvmrg.name

  security_rule {
    name                       = "ssh_rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "linuxvmnicnsg" {
  network_interface_id      = azurerm_network_interface.vmnic.id
  network_security_group_id = azurerm_network_security_group.linuxvmnsg.id
}

resource "azurerm_public_ip" "linuxvmpublicip" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.linuxvmrg.location
  resource_group_name = azurerm_resource_group.linuxvmrg.name
  allocation_method   = "Static"
}