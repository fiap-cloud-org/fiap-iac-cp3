# VPCs
resource "aws_vpc" "vpc10" {
  cidr_block           = var.vpc10_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "vpc10"
  }
}

resource "aws_vpc" "vpc20" {
  cidr_block           = var.vpc20_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "vpc20"
  }
}

# SUB-REDES
resource "aws_subnet" "sn_vpc10_pub" {
  vpc_id                  = aws_vpc.vpc10.id
  cidr_block              = var.vpc10_public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "sn_vpc10"
  }
}

resource "aws_subnet" "sn_vpc20_priv" {
  vpc_id            = aws_vpc.vpc20.id
  cidr_block        = var.vpc20_private_subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "sn_vpc20"
  }
}

# INTERNET GATEWAY (só a vpc10 sai para a internet)
resource "aws_internet_gateway" "igw_vpc10" {
  vpc_id = aws_vpc.vpc10.id
  tags = {
    Name = "igw_vpc10"
  }
}

# ROUTE TABLES
resource "aws_route_table" "rt_sn_vpc10_pub" {
  vpc_id = aws_vpc.vpc10.id
  route {
    cidr_block                = var.vpc20_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_vpc10.id
  }
  tags = {
    Name = "rt_sn_vpc10_pub"
  }
}

resource "aws_route_table" "rt_sn_vpc20_priv" {
  vpc_id = aws_vpc.vpc20.id
  route {
    cidr_block                = var.vpc10_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  }
  tags = {
    Name = "rt_sn_vpc20_priv"
  }
}

resource "aws_route_table_association" "rt_sn_vpc10_pub_To_sn_vpc10_pub" {
  subnet_id      = aws_subnet.sn_vpc10_pub.id
  route_table_id = aws_route_table.rt_sn_vpc10_pub.id
}

resource "aws_route_table_association" "rt_sn_vpc20_priv_To_sn_vpc20_priv" {
  subnet_id      = aws_subnet.sn_vpc20_priv.id
  route_table_id = aws_route_table.rt_sn_vpc20_priv.id
}
