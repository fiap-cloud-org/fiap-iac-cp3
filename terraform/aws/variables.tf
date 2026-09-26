variable "region" {
  description = "Região da AWS onde as duas VPCs são criadas."
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "Zona de disponibilidade das sub-redes."
  type        = string
  default     = "us-east-1a"
}

variable "vpc10_cidr" {
  description = "Faixa da vpc10 (VPC com sub-rede pública)."
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc10_public_subnet_cidr" {
  description = "Faixa da sub-rede pública da vpc10."
  type        = string
  default     = "10.0.1.0/24"
}

variable "vpc20_cidr" {
  description = "Faixa da vpc20 (VPC só com sub-rede privada)."
  type        = string
  default     = "10.1.0.0/16"
}

variable "vpc20_private_subnet_cidr" {
  description = "Faixa da sub-rede privada da vpc20."
  type        = string
  default     = "10.1.1.0/24"
}

variable "deploy_vms" {
  description = "Cria as duas EC2 (uma na sub-rede pública da vpc10, outra na privada da vpc20). false sobe só a rede e o peering."
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "Tipo das instâncias EC2."
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair existente na conta para SSH (no AWS Academy: vockey). null cria as instâncias sem chave."
  type        = string
  default     = null
}

variable "ssh_source_cidr" {
  description = "Origem liberada para SSH (porta 22) na instância pública. Use o seu IP com /32."
  type        = string
  default     = "0.0.0.0/0"
}
