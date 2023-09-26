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
  name                            = "${var.name}-rg"
  location                        = var.location
}

# Se crea un Virtual Network.
resource "azurerm_virtual_network" "vn" {
  name                            = "${var.name}-vn"
  address_space                   = ["10.0.0.0/16"]
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
}

# Se crea una Subnet
resource "azurerm_subnet" "sn" {
  name                            = "${var.name}-sn"
  resource_group_name             = azurerm_resource_group.rg.name
  virtual_network_name            = azurerm_virtual_network.vn.name
  address_prefixes                = ["10.0.1.0/24"]
}

# Se crea modulo para una Virtual Machine
module "vm" {
  source = "./modules/vm"
  rg_name = azurerm_resource_group.rg.name
  rg_location = azurerm_resource_group.rg.location
  sn_id = azurerm_subnet.sn.id
  name = var.name
  username = var.username
}