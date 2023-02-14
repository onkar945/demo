terraform {
  backend "azurerm" {
    resource_group_name  = "tfbackend"
    storage_account_name = "stg826111"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}