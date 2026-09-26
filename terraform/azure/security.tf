# Um NSG compartilhado pelas duas sub-redes: HTTP aberto, SSH pela origem
# definida em var.ssh_source_cidr.
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
    source_address_prefix      = var.ssh_source_cidr
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsgsubnet1a_vnet10" {
  subnet_id                 = azurerm_subnet.subnet1a_vnet10.id
  network_security_group_id = azurerm_network_security_group.nsgvm.id
}

resource "azurerm_subnet_network_security_group_association" "nsgsubnet1c_vnet20" {
  subnet_id                 = azurerm_subnet.subnet1c_vnet20.id
  network_security_group_id = azurerm_network_security_group.nsgvm.id
}
