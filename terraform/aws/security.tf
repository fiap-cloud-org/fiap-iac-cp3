# Instância pública: HTTP aberto, SSH pela origem configurada e tudo liberado
# entre as duas VPCs (tráfego do peering).
resource "aws_security_group" "sg_ec2_vpc10_pub" {
  name        = "sg_ec2_vpc10_pub"
  description = "EC2 publica da vpc10"
  vpc_id      = aws_vpc.vpc10.id

  ingress {
    description = "Trafego interno das duas VPCs"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc10_cidr, var.vpc20_cidr]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_source_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "sg_ec2_vpc10_pub"
  }
}

# Instância privada: só recebe tráfego das duas VPCs.
resource "aws_security_group" "sg_ec2_vpc20_priv" {
  name        = "sg_ec2_vpc20_priv"
  description = "EC2 privada da vpc20"
  vpc_id      = aws_vpc.vpc20.id

  ingress {
    description = "Trafego interno das duas VPCs"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc10_cidr, var.vpc20_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "sg_ec2_vpc20_priv"
  }
}
