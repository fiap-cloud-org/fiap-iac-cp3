locals {
  vms = var.deploy_vms ? {
    vm01 = {
      subnet_id    = azurerm_subnet.subnet1a_vnet10.id
      subnet_name  = azurerm_subnet.subnet1a_vnet10.name
      network_name = azurerm_virtual_network.vnet10.name
      network_cidr = var.vnet10_cidr
      private_ip   = cidrhost(var.vnet10_subnet_cidr, 10)
      public       = true
      peer         = "vm02"
    }
    vm02 = {
      subnet_id    = azurerm_subnet.subnet1c_vnet20.id
      subnet_name  = azurerm_subnet.subnet1c_vnet20.name
      network_name = azurerm_virtual_network.vnet20.name
      network_cidr = var.vnet20_cidr
      private_ip   = cidrhost(var.vnet20_subnet_cidr, 10)
      public       = false
      peer         = "vm01"
    }
  } : {}
}

# Página e teste de peering de cada VM (mesmo módulo usado na AWS).
module "web_page" {
  source   = "../modules/web-page"
  for_each = local.vms

  cloud             = "Azure"
  region            = var.location
  vm_name           = each.key
  network_name      = each.value.network_name
  network_cidr      = each.value.network_cidr
  subnet_name       = each.value.subnet_name
  private_ip        = each.value.private_ip
  public            = each.value.public
  peer_name         = each.value.peer
  peer_ip           = local.vms[each.value.peer].private_ip
  peer_network_name = local.vms[each.value.peer].network_name
  peer_network_cidr = local.vms[each.value.peer].network_cidr
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

  custom_data = base64encode(module.web_page[each.key].user_data)
}
