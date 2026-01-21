# Terraform Tests for Network Module
# Run with: terraform test

mock_provider "azurerm" {}

# =============================================================================
# Test: Network module creates VNet and Subnet
# =============================================================================
run "network_module_plan" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
  }

  assert {
    condition     = azurerm_virtual_network.main.name == "test-vnet"
    error_message = "VNet name should be 'test-vnet'"
  }

  assert {
    condition     = azurerm_virtual_network.main.address_space[0] == "10.0.0.0/16"
    error_message = "VNet address space should be '10.0.0.0/16'"
  }

  assert {
    condition     = azurerm_subnet.main.name == "test-subnet"
    error_message = "Subnet name should be 'test-subnet'"
  }

  assert {
    condition     = azurerm_subnet.main.address_prefixes[0] == "10.0.1.0/24"
    error_message = "Subnet address prefix should be '10.0.1.0/24'"
  }
}

# =============================================================================
# Test: Network module uses correct resource group
# =============================================================================
run "network_uses_correct_resource_group" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    prefix                  = "prod"
    resource_group_name     = "rg-production"
    resource_group_location = "West Europe"
  }

  assert {
    condition     = azurerm_virtual_network.main.resource_group_name == "rg-production"
    error_message = "VNet should be in 'rg-production' resource group"
  }

  assert {
    condition     = azurerm_virtual_network.main.location == "West Europe"
    error_message = "VNet location should be 'West Europe'"
  }
}

# =============================================================================
# Test: Network module with different prefixes
# =============================================================================
run "network_prefix_customization" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    prefix                  = "dev-app"
    resource_group_name     = "rg-dev"
    resource_group_location = "Germany West Central"
  }

  assert {
    condition     = azurerm_virtual_network.main.name == "dev-app-vnet"
    error_message = "VNet name should use the custom prefix"
  }

  assert {
    condition     = azurerm_subnet.main.name == "dev-app-subnet"
    error_message = "Subnet name should use the custom prefix"
  }
}
