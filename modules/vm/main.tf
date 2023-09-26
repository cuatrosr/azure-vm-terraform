# Se crea un Public Ip
resource "azurerm_public_ip" "pi" {
  name                = "${var.name}-pi"
  resource_group_name = var.rg_name
  location            = var.rg_location
  allocation_method   = "Static"
}

# Se crea una Network Interface
resource "azurerm_network_interface" "ni" {
  name                            = "${var.name}-ni"
  location                        = var.rg_location
  resource_group_name             = var.rg_name

  ip_configuration {
    name                          = "${var.name}-ni-ic"
    subnet_id                     = var.sn_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pi.id
  }
}

# Se crea una nueva SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Output the public key to a file
resource "local_file" "ssh_key_public" {
  filename = ".ssh/my-azure-key.pub"
  content  = tls_private_key.ssh_key.public_key_openssh
}

# Output the private key to a file
resource "local_file" "ssh_key_private" {
  filename = ".ssh/my-azure-key"
  content  = tls_private_key.ssh_key.private_key_openssh
}

resource "azurerm_virtual_machine" "vm" {
  name                = "${var.name}-vm"
  location            = var.rg_location
  resource_group_name = var.rg_name
  network_interface_ids = [azurerm_network_interface.ni.id]
  vm_size             = "Standard_DS1_v2"
  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.name}-vm-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = var.username
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
        path       = "/home/adminuser/.ssh/authorized_keys"
        key_data   = local_file.ssh_key_public.content
    }
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name}-nsg"
  location            = var.rg_location
  resource_group_name = var.rg_name

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

resource "azurerm_network_interface_security_group_association" "nisg" {
    network_interface_id      = azurerm_network_interface.ni.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}