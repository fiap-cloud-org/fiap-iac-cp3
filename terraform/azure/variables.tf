variable "resource_group_name" {
  description = "Nome do resource group que recebe todos os recursos."
  type        = string
  default     = "rg-fiap-iac-cp3"
}

variable "location" {
  description = "Região da Azure."
  type        = string
  default     = "brazilsouth"
}

variable "vnet10_cidr" {
  description = "Faixa da vnet10."
  type        = string
  default     = "10.0.0.0/16"
}

variable "vnet10_subnet_cidr" {
  description = "Faixa da sub-rede subnet1a_vnet10."
  type        = string
  default     = "10.0.5.0/24"
}

variable "vnet20_cidr" {
  description = "Faixa da vnet20."
  type        = string
  default     = "10.1.0.0/16"
}

variable "vnet20_subnet_cidr" {
  description = "Faixa da sub-rede subnet1c_vnet20."
  type        = string
  default     = "10.1.6.0/24"
}

variable "ssh_source_cidr" {
  description = "Origem liberada para SSH (porta 22) no NSG. Use o seu IP com /32."
  type        = string
  default     = "*"
}
