resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# VNETS
resource "azurerm_virtual_network" "vnet10" {
  name                = "vnet10"
  address_space       = [var.vnet10_cidr]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "vnet20" {
  name                = "vnet20"
  address_space       = [var.vnet20_cidr]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# SUB-REDES
resource "azurerm_subnet" "subnet1a_vnet10" {
  name                 = "subnet1a_vnet10"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet10.name
  address_prefixes     = [var.vnet10_subnet_cidr]
}

resource "azurerm_subnet" "subnet1c_vnet20" {
  name                 = "subnet1c_vnet20"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet20.name
  address_prefixes     = [var.vnet20_subnet_cidr]
}
