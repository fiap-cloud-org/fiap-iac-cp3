output "resource_group" {
  description = "Resource group com todos os recursos."
  value       = azurerm_resource_group.rg.name
}

output "vnet10_id" {
  description = "ID da vnet10."
  value       = azurerm_virtual_network.vnet10.id
}

output "vnet20_id" {
  description = "ID da vnet20."
  value       = azurerm_virtual_network.vnet20.id
}
