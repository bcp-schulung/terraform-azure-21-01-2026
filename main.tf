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
}

# Create the Virtual Machine
module "vm" {
  count = 2
  source                  = "./modules/vm"

  name = "${var.prefix}-vm${count.index + 1}"
  resource_group_name     = data.azurerm_resource_group.lab.name
  resource_group_location = data.azurerm_resource_group.lab.location
  prefix = var.prefix
  subnet_id = module.network.subnet_id
  security_group_id = module.security-group.security_group_id
}