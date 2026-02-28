terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.62.0"
    }
  }
  backend "azurerm" {
    key                  = " "
    resource_group_name  = " "
    storage_account_name = " "
    container_name       = " "
  }
}

provider "azurerm" {
  features {

  }
  subscription_id = var.subscription_id
}