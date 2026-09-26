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

resource "aws_instance" "instance_sn_vpc10_pub" {
  count                  = var.deploy_vms ? 1 : 0
  ami                    = data.aws_ami.ubuntu[0].id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.sn_vpc10_pub.id
  private_ip             = cidrhost(var.vpc10_public_subnet_cidr, 10)
  vpc_security_group_ids = [aws_security_group.sg_ec2_vpc10_pub.id]
  key_name               = var.key_name

  user_data = <<-USERDATA
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    echo "fiap-iac-cp3 - AWS - instance_sn_vpc10_pub" > /var/www/html/index.html
  USERDATA

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
  private_ip             = cidrhost(var.vpc20_private_subnet_cidr, 10)
  vpc_security_group_ids = [aws_security_group.sg_ec2_vpc20_priv.id]
  key_name               = var.key_name

  tags = {
    Name = "instance_sn_vpc20_priv"
  }
}
