# Ubuntu 22.04 oficial da Canonical, a mesma imagem das VMs da Azure.
data "aws_ami" "ubuntu" {
  count       = var.deploy_vms ? 1 : 0
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

locals {
  vpc10_instance_ip = cidrhost(var.vpc10_public_subnet_cidr, 10)
  vpc20_instance_ip = cidrhost(var.vpc20_private_subnet_cidr, 10)
}

# Página e teste de peering de cada instância (mesmo módulo usado na Azure).
module "web_page_vpc10" {
  source = "../modules/web-page"

  cloud             = "AWS"
  region            = var.region
  vm_name           = "instance_sn_vpc10_pub"
  network_name      = "vpc10"
  network_cidr      = var.vpc10_cidr
  subnet_name       = "sn_vpc10_pub"
  private_ip        = local.vpc10_instance_ip
  public            = true
  peer_name         = "instance_sn_vpc20_priv"
  peer_ip           = local.vpc20_instance_ip
  peer_network_name = "vpc20"
  peer_network_cidr = var.vpc20_cidr
}

module "web_page_vpc20" {
  source = "../modules/web-page"

  cloud             = "AWS"
  region            = var.region
  vm_name           = "instance_sn_vpc20_priv"
  network_name      = "vpc20"
  network_cidr      = var.vpc20_cidr
  subnet_name       = "sn_vpc20_priv"
  private_ip        = local.vpc20_instance_ip
  public            = false
  peer_name         = "instance_sn_vpc10_pub"
  peer_ip           = local.vpc10_instance_ip
  peer_network_name = "vpc10"
  peer_network_cidr = var.vpc10_cidr
}

resource "aws_instance" "instance_sn_vpc10_pub" {
  count                  = var.deploy_vms ? 1 : 0
  ami                    = data.aws_ami.ubuntu[0].id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.sn_vpc10_pub.id
  private_ip             = local.vpc10_instance_ip
  vpc_security_group_ids = [aws_security_group.sg_ec2_vpc10_pub.id]
  key_name               = var.key_name

  user_data                   = module.web_page_vpc10.user_data
  user_data_replace_on_change = true

  tags = {
    Name = "instance_sn_vpc10_pub"
  }
}

# Sem internet (a vpc20 não tem IGW nem NAT): só é alcançada pelo peering.
resource "aws_instance" "instance_sn_vpc20_priv" {
  count                  = var.deploy_vms ? 1 : 0
  ami                    = data.aws_ami.ubuntu[0].id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.sn_vpc20_priv.id
  private_ip             = local.vpc20_instance_ip
  vpc_security_group_ids = [aws_security_group.sg_ec2_vpc20_priv.id]
  key_name               = var.key_name

  user_data                   = module.web_page_vpc20.user_data
  user_data_replace_on_change = true

  tags = {
    Name = "instance_sn_vpc20_priv"
  }
}
