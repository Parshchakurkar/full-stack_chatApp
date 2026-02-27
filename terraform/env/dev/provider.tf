terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.76.0"
    }
  }
  backend "azurerm" {
    key                  = "dataapp-dev.tfstate"
    resource_group_name  = "chatapp-resources"
    storage_account_name = "chatappresources1"
    container_name       = "terraform"
  }
}

provider "azurerm" {
  features {

  }
  subscription_id = var.subscription_id
}