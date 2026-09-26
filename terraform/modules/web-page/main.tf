# Módulo sem recursos: só renderiza o script de inicialização (user data /
# custom data) que instala o servidor web, grava a página e agenda o teste
# de peering. Usado pelas duas nuvens para a página ser idêntica.
locals {
  page = templatefile("${path.module}/templates/index.html.tftpl", {
    cloud             = var.cloud
    region            = var.region
    vm_name           = var.vm_name
    network_name      = var.network_name
    network_cidr      = var.network_cidr
    subnet_name       = var.subnet_name
    private_ip        = var.private_ip
    public            = var.public
    peer_name         = var.peer_name
    peer_ip           = var.peer_ip
    peer_network_name = var.peer_network_name
    peer_network_cidr = var.peer_network_cidr
  })
}

output "user_data" {
  description = "Script bash para user_data (AWS) ou custom_data (Azure, em base64)."
  value = templatefile("${path.module}/templates/cloud-init.sh.tftpl", {
    index_b64 = base64encode(local.page)
    vm_name   = var.vm_name
    peer_name = var.peer_name
    peer_ip   = var.peer_ip
  })
}

output "page" {
  description = "HTML renderizado (útil para pré-visualizar a página localmente)."
  value       = local.page
}
