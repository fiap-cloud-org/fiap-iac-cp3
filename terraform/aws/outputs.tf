output "vpc10_id" {
  description = "ID da vpc10."
  value       = aws_vpc.vpc10.id
}

output "vpc20_id" {
  description = "ID da vpc20."
  value       = aws_vpc.vpc20.id
}

output "vpc_peering_id" {
  description = "ID do peering entre vpc10 e vpc20."
  value       = aws_vpc_peering_connection.vpc_peering.id
}

output "vpc_peering_status" {
  description = "Status do peering (active quando aceito)."
  value       = aws_vpc_peering_connection.vpc_peering.accept_status
}
