terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.62.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.1.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
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

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes =  {
    config_path     = "~/.kube/config"
  }
}