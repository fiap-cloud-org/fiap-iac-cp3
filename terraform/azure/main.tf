resource "azurerm_resource_group" "rg" {
  name     = "rg-fiap-iac-cp3"
  location = "brazilsouth"
}

resource "azurerm_virtual_network" "vnet10" {
  name                = "vnet10"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "vnet20" {
  name                = "vnet20"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet1a_vnet10" {
  name                 = "subnet1a_vnet10"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet10.name
  address_prefixes     = ["10.0.5.0/24"]
}

resource "azurerm_subnet" "subnet1c_vnet20" {
  name                 = "subnet1c_vnet20"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet20.name
  address_prefixes     = ["10.1.6.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "nsgsubnet1a_vnet10" {
  subnet_id                 = azurerm_subnet.subnet1a_vnet10.id
  network_security_group_id = azurerm_network_security_group.nsgvm.id
}

resource "azurerm_subnet_network_security_group_association" "nsgsubnet1c_vnet20" {
  subnet_id                 = azurerm_subnet.subnet1c_vnet20.id
  network_security_group_id = azurerm_network_security_group.nsgvm.id
}

resource "azurerm_virtual_network_peering" "vnet10-to-vnet20" {
  name                         = "vnet10-to-vnet20"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnet10.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet20.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "vnet20-to-vnet10" {
  name                         = "vnet20-to-vnet10"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnet20.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet10.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_network_security_group" "nsgvm" {
  name                = "nsgvm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "SSH"
    priority                   = 1011
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

