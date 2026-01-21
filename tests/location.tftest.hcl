# Location and Region Tests
# Validates that resources are deployed to correct regions

mock_provider "azurerm" {}

# =============================================================================
# Test: Network resources use specified location
# =============================================================================
run "network_uses_specified_location" {
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
    condition     = azurerm_virtual_network.main.location == "Germany West Central"
    error_message = "VNet should be in Germany West Central"
  }
}

# =============================================================================
# Test: NSG uses specified location
# =============================================================================
run "nsg_uses_specified_location" {
  command = plan

  module {
    source = "./modules/security-group"
  }

  variables {
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "West Europe"
  }

  assert {
    condition     = azurerm_network_security_group.main.location == "West Europe"
    error_message = "NSG should be in West Europe"
  }
}

# =============================================================================
# Test: VM resources use specified location
# =============================================================================
run "vm_uses_specified_location" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    name                    = "test-vm"
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "East US"
    subnet_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
    security_group_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/networkSecurityGroups/nsg"
    ssh_public_key_path     = "./tests/fixtures/test_ssh_key.pub"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.main.location == "East US"
    error_message = "VM should be in East US"
  }

  assert {
    condition     = azurerm_public_ip.main.location == "East US"
    error_message = "Public IP should be in same region as VM"
  }

  assert {
    condition     = azurerm_network_interface.main.location == "East US"
    error_message = "NIC should be in same region as VM"
  }
}

# =============================================================================
# Test: All VM resources in same region
# =============================================================================
run "all_vm_resources_same_region" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    name                    = "test-vm"
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "North Europe"
    subnet_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
    security_group_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/networkSecurityGroups/nsg"
    ssh_public_key_path     = "./tests/fixtures/test_ssh_key.pub"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.main.location == azurerm_public_ip.main.location
    error_message = "VM and Public IP must be in the same region"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.main.location == azurerm_network_interface.main.location
    error_message = "VM and NIC must be in the same region"
  }
}

# =============================================================================
# Test: Resources use different regions correctly
# =============================================================================
run "different_region_deployment" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    prefix                  = "asia"
    resource_group_name     = "rg-asia"
    resource_group_location = "Southeast Asia"
  }

  assert {
    condition     = azurerm_virtual_network.main.location == "Southeast Asia"
    error_message = "Resources should be deployable to Southeast Asia"
  }
}
