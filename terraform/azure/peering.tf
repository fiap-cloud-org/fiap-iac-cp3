# Na Azure o peering é feito nos dois sentidos: um recurso em cada VNet.
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
