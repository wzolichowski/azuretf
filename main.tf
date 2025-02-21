terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "terraform" {
  name     = "terraform-resource"
  location = "West Europe"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "terraform-vn" {
  name                = "terraform-network"
  resource_group_name = azurerm_resource_group.terraform.name
  location            = azurerm_resource_group.terraform.location
  address_space       = ["10.123.0.0/16"]
  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "terraform_sn" {
  name                 = "terraform_subnet"
  resource_group_name  = azurerm_resource_group.terraform.name
  virtual_network_name = azurerm_virtual_network.terraform-vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "sec_group" {
  name                = "terraformsecgroup"
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name
  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "sec_group_rules" {
  name                        = "network_dev_rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*" # Allow all inbound traffic (restrict this in production)
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.terraform.name
  network_security_group_name = azurerm_network_security_group.sec_group.name
}

resource "azurerm_subnet_network_security_group_association" "subnet_security_association" {
  subnet_id                 = azurerm_subnet.terraform_sn.id
  network_security_group_id = azurerm_network_security_group.sec_group.id
}

resource "azurerm_public_ip" "terraformip" {
  name                = "terraformip"
  resource_group_name = azurerm_resource_group.terraform.name
  location            = azurerm_resource_group.terraform.location
  allocation_method   = "Static"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "tfnetworkinterface" {
  name                = "networkinterface"
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.terraform_sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.terraformip.id
  }
}

resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                  = "tflinuxvm"
  resource_group_name   = azurerm_resource_group.terraform.name
  location              = azurerm_resource_group.terraform.location
  size                  = "Standard_B1s"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.tfnetworkinterface.id]

  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/virtualazurekey.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile("windows-ssh-script.tpl", {
      hostname     = self.public_ip_address,
      user         = "azureuser",
      identityfile = "~/.ssh/virtualazurekey"
    })
    interpreter = ["Powershell", "-Command"]
  }

  tags = {
    environment = "dev"
  }
}

data "azurerm_public_ip" "linuxvm-ip-data" {
  name                = azurerm_public_ip.terraformip.name
  resource_group_name = azurerm_resource_group.terraform.name
}

output "public_ip_address" { #terraform output
  value = "${azurerm_linux_virtual_machine.linuxvm.name}: ${data.azurerm_public_ip.linuxvm-ip-data.ip_address}"
}