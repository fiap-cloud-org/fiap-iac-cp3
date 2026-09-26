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

output "vm01_public_ip" {
  description = "IP público da vm01 (site na porta 80)."
  value       = var.deploy_vms ? azurerm_public_ip.vm01[0].ip_address : null
}

output "vm01_url" {
  description = "Endereço do site servido pela vm01."
  value       = var.deploy_vms ? "http://${coalesce(azurerm_public_ip.vm01[0].fqdn, azurerm_public_ip.vm01[0].ip_address)}" : null
}

output "vm_private_ips" {
  description = "IPs privados das VMs."
  value       = { for k, v in local.vms : k => v.private_ip }
}
