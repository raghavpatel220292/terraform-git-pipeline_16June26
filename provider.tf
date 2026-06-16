terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.76.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "remote_rg"
    storage_account_name = "remotestg"
    container_name       = "remote-tfstate"
    key                  = "remote.tfstate"
  }
}

provider "azurerm" {
  features {}

}