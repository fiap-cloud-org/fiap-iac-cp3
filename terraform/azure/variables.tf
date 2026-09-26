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

variable "deploy_vms" {
  description = "Cria as duas VMs (vm01 na vnet10 com IP público, vm02 na vnet20 só com IP privado). false sobe só a rede e o peering."
  type        = bool
  default     = true
}

variable "vm_size" {
  description = "Tamanho das VMs."
  type        = string
  default     = "Standard_DS1_v2"
}

variable "admin_username" {
  description = "Usuário administrador das VMs."
  type        = string
  default     = "vmuser"
}

variable "admin_ssh_public_key" {
  description = "Chave pública SSH (conteúdo de ~/.ssh/id_ed25519.pub ou id_rsa.pub). As VMs não aceitam senha."
  type        = string
  default     = null

  validation {
    condition     = !var.deploy_vms || var.admin_ssh_public_key != null
    error_message = "Com deploy_vms = true, informe admin_ssh_public_key (ou TF_VAR_admin_ssh_public_key)."
  }
}

variable "public_dns_label" {
  description = "Rótulo DNS opcional do IP público da vm01 (<rotulo>.<regiao>.cloudapp.azure.com). Precisa ser único na região."
  type        = string
  default     = null
}
