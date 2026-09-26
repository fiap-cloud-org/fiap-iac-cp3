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

output "public_instance_ip" {
  description = "IP público da EC2 da vpc10 (site na porta 80)."
  value       = var.deploy_vms ? aws_instance.instance_sn_vpc10_pub[0].public_ip : null
}

output "public_instance_url" {
  description = "Endereço do site servido pela EC2 pública."
  value       = var.deploy_vms ? "http://${aws_instance.instance_sn_vpc10_pub[0].public_dns}" : null
}

output "instance_private_ips" {
  description = "IPs privados das duas EC2."
  value = var.deploy_vms ? {
    instance_sn_vpc10_pub  = aws_instance.instance_sn_vpc10_pub[0].private_ip
    instance_sn_vpc20_priv = aws_instance.instance_sn_vpc20_priv[0].private_ip
  } : {}
}
