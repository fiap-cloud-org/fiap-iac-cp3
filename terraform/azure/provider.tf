terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.5"
    }
  }

  # Configuração parcial: resource group, storage account e container vêm
  # do backend.hcl (terraform init -backend-config=backend.hcl).
  backend "azurerm" {}
}

provider "azurerm" {
  resource_provider_registrations = "none"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
