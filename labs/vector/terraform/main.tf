provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.namespace}-vector"
  location = var.region
}

resource "azurerm_public_ip" "main" {
  name                = "vector-public-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.namespace}-vector"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "vector-ip"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "key_file" {
  filename        = "${var.namespace}-private_key.pem"
  file_permission = "600"
  content         = tls_private_key.ssh.private_key_pem
}

resource "azurerm_linux_virtual_machine" "main" {
  name                  = "${var.namespace}-vector"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  network_interface_ids = [azurerm_network_interface.main.id]
  size                  = "Standard_B1s"
  admin_username        = var.username

# az vm image list --output table
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = var.username
    public_key = tls_private_key.ssh.public_key_openssh
  }

  tags = {
    creator = var.creator
  }
}

resource "azurerm_dns_a_record" "main" {
  name                = "vector.${var.namespace}"
  zone_name           = var.domain
  resource_group_name = var.domain-rg
  ttl                 = 60
  records             = [azurerm_public_ip.main.ip_address]
}


resource "local_file" "ansible_inventory" {
  content  = templatefile("inventory.tmpl", { namespace = var.namespace, domain = var.domain })
  filename = "../ansible/${var.namespace}-inventory.txt"
}
