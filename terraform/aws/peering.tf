# Peering na mesma conta e região: auto_accept aceita a conexão na hora.
resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id      = aws_vpc.vpc10.id
  peer_vpc_id = aws_vpc.vpc20.id
  auto_accept = true
  tags = {
    Name = "vpc_peering"
  }
}
