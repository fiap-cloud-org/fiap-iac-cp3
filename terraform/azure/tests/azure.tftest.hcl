# terraform test com provider simulado: nenhuma chamada à Azure, nenhuma
# credencial. Confere a lógica do código (peering, NSG, VMs sem senha).
# Os IDs simulados precisam ter o formato de ID da Azure, porque o provider
# valida as referências entre recursos.
mock_provider "azurerm" {
  mock_resource "azurerm_resource_group" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-fiap-iac-cp3"
    }
  }

  mock_resource "azurerm_virtual_network" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-fiap-iac-cp3/providers/Microsoft.Network/virtualNetworks/vnet-teste"
    }
  }

  mock_resource "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-fiap-iac-cp3/providers/Microsoft.Network/virtualNetworks/vnet-teste/subnets/subnet-teste"
    }
  }

  mock_resource "azurerm_network_security_group" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-fiap-iac-cp3/providers/Microsoft.Network/networkSecurityGroups/nsgvm"
    }
  }

  mock_resource "azurerm_public_ip" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-fiap-iac-cp3/providers/Microsoft.Network/publicIPAddresses/pip-vm01"
    }
  }

  mock_resource "azurerm_network_interface" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-fiap-iac-cp3/providers/Microsoft.Network/networkInterfaces/nic-teste"
    }
  }
}

variables {
  # Chave pública de teste; a privada foi descartada na geração.
  admin_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEH9HV6NXF+2qB3hjdq6txtst/Wkzx0F+m31cGymUTet teste-sem-uso"
}

run "rede_peering_e_vms" {
  command = apply

  assert {
    condition     = azurerm_virtual_network_peering.vnet10-to-vnet20.remote_virtual_network_id == azurerm_virtual_network.vnet20.id
    error_message = "Peering vnet10 -> vnet20 apontando para a VNet errada."
  }

  assert {
    condition     = azurerm_virtual_network_peering.vnet20-to-vnet10.remote_virtual_network_id == azurerm_virtual_network.vnet10.id
    error_message = "Peering vnet20 -> vnet10 apontando para a VNet errada."
  }

  assert {
    condition     = alltrue([for vm in azurerm_linux_virtual_machine.vm : vm.disable_password_authentication && vm.admin_password == null])
    error_message = "As VMs não podem aceitar senha."
  }

  assert {
    condition     = azurerm_network_interface.vm["vm01"].ip_configuration[0].private_ip_address == "10.0.5.10" && azurerm_network_interface.vm["vm02"].ip_configuration[0].private_ip_address == "10.1.6.10"
    error_message = "IPs privados fixos das VMs errados."
  }

  assert {
    condition     = azurerm_network_interface.vm["vm01"].ip_configuration[0].public_ip_address_id != null && azurerm_network_interface.vm["vm02"].ip_configuration[0].public_ip_address_id == null
    error_message = "Só a vm01 pode ter IP público."
  }

  assert {
    condition     = one([for r in azurerm_network_security_group.nsgvm.security_rule : r.name if r.destination_port_range == "22"]) == "SSH"
    error_message = "A regra da porta 22 deve se chamar SSH."
  }

  assert {
    condition     = strcontains(module.web_page["vm01"].user_data, "http://10.1.6.10/") && strcontains(module.web_page["vm02"].user_data, "http://10.0.5.10/")
    error_message = "Cada VM deve testar o IP privado da outra."
  }
}

run "vms_exigem_chave_ssh" {
  command = plan

  variables {
    admin_ssh_public_key = null
  }

  expect_failures = [var.admin_ssh_public_key]
}

run "somente_rede" {
  command = apply

  variables {
    deploy_vms           = false
    admin_ssh_public_key = null
  }

  assert {
    condition     = length(azurerm_linux_virtual_machine.vm) == 0 && length(azurerm_public_ip.vm01) == 0
    error_message = "Com deploy_vms = false nenhuma VM nem IP público deve ser criado."
  }
}
