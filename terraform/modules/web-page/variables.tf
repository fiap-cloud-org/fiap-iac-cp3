variable "cloud" {
  description = "Nome da nuvem exibido na página (AWS ou Azure)."
  type        = string

  validation {
    condition     = contains(["AWS", "Azure"], var.cloud)
    error_message = "cloud deve ser AWS ou Azure."
  }
}

variable "region" {
  description = "Região onde a máquina roda."
  type        = string
}

variable "vm_name" {
  description = "Nome da VM/instância."
  type        = string
}

variable "network_name" {
  description = "Nome da VPC/VNet da máquina."
  type        = string
}

variable "network_cidr" {
  description = "Faixa da VPC/VNet da máquina."
  type        = string
}

variable "subnet_name" {
  description = "Nome da sub-rede da máquina."
  type        = string
}

variable "private_ip" {
  description = "IP privado da máquina."
  type        = string
}

variable "public" {
  description = "true se a máquina tem IP público."
  type        = bool
}

variable "peer_name" {
  description = "Nome da máquina do outro lado do peering."
  type        = string
}

variable "peer_ip" {
  description = "IP privado da máquina do outro lado do peering."
  type        = string
}

variable "peer_network_name" {
  description = "Nome da VPC/VNet do outro lado do peering."
  type        = string
}

variable "peer_network_cidr" {
  description = "Faixa da VPC/VNet do outro lado do peering."
  type        = string
}
