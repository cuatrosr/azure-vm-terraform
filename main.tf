# Definición del provider que ocuparemos
provider "azurerm" {
  features {
    resource_group {
        prevent_deletion_if_contains_resources = false
    }
  }
}

# Se crea el grupo de recursos
resource "azurerm_resource_group" "rg" {
  name                            = var.name_rg
  location                        = var.location
}

# Se crea un Virtual Network.
resource "azurerm_virtual_network" "vn" {
  name                            = var.name_vn
  address_space                   = [var.config_vn_as]
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
}

# Se crea una Subnet
resource "azurerm_subnet" "sn" {
  name                            = var.name_sn
  resource_group_name             = azurerm_resource_group.rg.name
  virtual_network_name            = azurerm_virtual_network.vn.name
  address_prefixes                = [var.config_sn_ap]
}

# Se crea un Public Ip
resource "azurerm_public_ip" "pi" {
  name                = var.name_pi
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

# Se crea una Network Interface
resource "azurerm_network_interface" "ni" {
  name                            = var.name_ni
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = var.name_ni_ic
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pi.id
  }
}

# Se crea una Virtual Machine
resource "azurerm_virtual_machine" "vm" {
  name                = var.name_vm
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.ni.id]
  vm_size             = "Standard_DS1_v2"
  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = var.name_vm_os
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "adminuser"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = var.name_nsg
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

