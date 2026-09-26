locals {
  vms = var.deploy_vms ? {
    vm01 = {
      subnet_id  = azurerm_subnet.subnet1a_vnet10.id
      private_ip = cidrhost(var.vnet10_subnet_cidr, 10)
      public     = true
    }
    vm02 = {
      subnet_id  = azurerm_subnet.subnet1c_vnet20.id
      private_ip = cidrhost(var.vnet20_subnet_cidr, 10)
      public     = false
    }
  } : {}
}

# Só a vm01 tem IP público. A vm02 é alcançada pela vm01 através do peering.
resource "azurerm_public_ip" "vm01" {
  count               = var.deploy_vms ? 1 : 0
  name                = "pip-vm01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.public_dns_label
}

resource "azurerm_network_interface" "vm" {
  for_each            = local.vms
  name                = each.key
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = each.key
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.private_ip
    public_ip_address_id          = each.value.public ? azurerm_public_ip.vm01[0].id : null
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each              = local.vms
  name                  = each.key
  computer_name         = each.key
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.vm[each.key].id]
  size                  = var.vm_size
  admin_username        = var.admin_username

  # Login só por chave SSH: nenhuma senha no código nem no state.
  disable_password_authentication = true
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    name                 = each.key
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  custom_data = base64encode(<<-CUSTOM_DATA
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    echo "fiap-iac-cp3 - Azure - ${each.key}" > /var/www/html/index.html
  CUSTOM_DATA
  )
}
