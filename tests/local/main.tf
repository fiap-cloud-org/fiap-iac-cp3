# Renderiza o script de inicialização das duas máquinas com o mesmo módulo
# usado na AWS e na Azure, trocando só os IPs pelos da rede Docker local.
module "web" {
  source = "../../terraform/modules/web-page"

  cloud             = "AWS"
  region            = "us-east-1"
  vm_name           = "instance_sn_vpc10_pub"
  network_name      = "vpc10"
  network_cidr      = "10.0.0.0/16"
  subnet_name       = "sn_vpc10_pub"
  private_ip        = "172.29.0.10"
  public            = true
  peer_name         = "instance_sn_vpc20_priv"
  peer_ip           = "172.29.0.20"
  peer_network_name = "vpc20"
  peer_network_cidr = "10.1.0.0/16"
}

module "priv" {
  source = "../../terraform/modules/web-page"

  cloud             = "AWS"
  region            = "us-east-1"
  vm_name           = "instance_sn_vpc20_priv"
  network_name      = "vpc20"
  network_cidr      = "10.1.0.0/16"
  subnet_name       = "sn_vpc20_priv"
  private_ip        = "172.29.0.20"
  public            = false
  peer_name         = "instance_sn_vpc10_pub"
  peer_ip           = "172.29.0.10"
  peer_network_name = "vpc10"
  peer_network_cidr = "10.0.0.0/16"
}

output "web" {
  value = module.web.user_data
}

output "priv" {
  value = module.priv.user_data
}
