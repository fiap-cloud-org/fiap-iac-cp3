# terraform test com provider simulado: nenhuma chamada à AWS, nenhuma
# credencial. Confere a lógica do código (CIDRs, rotas, VMs, página).
mock_provider "aws" {
  mock_data "aws_ami" {
    defaults = {
      id = "ami-0123456789abcdef0"
    }
  }
}

run "rede_peering_e_instancias" {
  command = apply

  assert {
    condition     = aws_vpc.vpc10.cidr_block == "10.0.0.0/16" && aws_vpc.vpc20.cidr_block == "10.1.0.0/16"
    error_message = "As VPCs devem usar 10.0.0.0/16 e 10.1.0.0/16."
  }

  assert {
    condition = anytrue([
      for r in aws_route_table.rt_sn_vpc10_pub.route :
      r.cidr_block == "10.1.0.0/16" && r.vpc_peering_connection_id == aws_vpc_peering_connection.vpc_peering.id
    ])
    error_message = "A vpc10 precisa de rota para a vpc20 pelo peering (vpc_peering_connection_id)."
  }

  assert {
    condition = anytrue([
      for r in aws_route_table.rt_sn_vpc20_priv.route :
      r.cidr_block == "10.0.0.0/16" && r.vpc_peering_connection_id == aws_vpc_peering_connection.vpc_peering.id
    ])
    error_message = "A vpc20 precisa de rota para a vpc10 pelo peering."
  }

  assert {
    condition     = length(aws_route_table.rt_sn_vpc20_priv.route) == 1
    error_message = "A vpc20 é privada: só pode ter a rota do peering."
  }

  assert {
    condition     = aws_instance.instance_sn_vpc10_pub[0].private_ip == "10.0.1.10" && aws_instance.instance_sn_vpc20_priv[0].private_ip == "10.1.1.10"
    error_message = "IPs privados fixos das instâncias errados."
  }

  assert {
    condition     = strcontains(module.web_page_vpc10.user_data, "http://10.1.1.10/") && strcontains(module.web_page_vpc20.user_data, "http://10.0.1.10/")
    error_message = "Cada instância deve testar o IP privado da outra."
  }
}

run "somente_rede" {
  command = apply

  variables {
    deploy_vms = false
  }

  assert {
    condition     = length(aws_instance.instance_sn_vpc10_pub) == 0 && length(aws_instance.instance_sn_vpc20_priv) == 0
    error_message = "Com deploy_vms = false nenhuma instância deve ser criada."
  }
}
