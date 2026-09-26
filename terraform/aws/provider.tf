terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }

  # Configuração parcial: bucket, tabela e região vêm do backend.hcl
  # (terraform init -backend-config=backend.hcl). Veja backend.hcl.example.
  backend "s3" {}
}

provider "aws" {
  region = var.region
}
