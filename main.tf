# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
}

# Create a Resource Group
data "azurerm_resource_group" "lab" {
  name = var.resource_group_name
}

module "network" {
  source                  = "./modules/network"

  prefix = var.prefix
  resource_group_name     = data.azurerm_resource_group.lab.name
  resource_group_location = data.azurerm_resource_group.lab.location
}


module "security-group" {
  source                  = "./modules/security-group"

  prefix = var.prefix
  resource_group_name     = data.azurerm_resource_group.lab.name
  resource_group_location = data.azurerm_resource_group.lab.location
  network_interface_id   = module.network.network_interface_id
}

# Create the Virtual Machine
module "vm" {
  source                  = "./modules/vm"

  resource_group_name     = data.azurerm_resource_group.lab.name
  resource_group_location = data.azurerm_resource_group.lab.location
  prefix = var.prefix
  public_ip = module.network.public_ip
  network_interface_id   = module.network.network_interface_id
}