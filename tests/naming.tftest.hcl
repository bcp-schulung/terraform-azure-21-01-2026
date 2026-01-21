# Naming Convention Tests
# Validates that all resources follow consistent naming patterns

mock_provider "azurerm" {}

# =============================================================================
# Test: All resources use prefix in naming
# =============================================================================
run "resources_use_prefix_naming" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    prefix                  = "myapp"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
  }

  assert {
    condition     = startswith(azurerm_virtual_network.main.name, "myapp-")
    error_message = "VNet name must start with prefix"
  }

  assert {
    condition     = startswith(azurerm_subnet.main.name, "myapp-")
    error_message = "Subnet name must start with prefix"
  }
}

# =============================================================================
# Test: Resource naming follows Azure conventions
# =============================================================================
run "naming_follows_azure_conventions" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    name                    = "prod-vm1"
    prefix                  = "prod"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
    subnet_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
    security_group_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/networkSecurityGroups/nsg"
    ssh_public_key_path     = "./tests/fixtures/test_ssh_key.pub"
  }

  # Resource names should end with appropriate suffixes
  assert {
    condition     = endswith(azurerm_public_ip.main.name, "-pip")
    error_message = "Public IP should end with '-pip' suffix"
  }

  assert {
    condition     = endswith(azurerm_network_interface.main.name, "-nic")
    error_message = "Network interface should end with '-nic' suffix"
  }
}

# =============================================================================
# Test: NSG naming convention
# =============================================================================
run "nsg_naming_convention" {
  command = plan

  module {
    source = "./modules/security-group"
  }

  variables {
    prefix                  = "webapp"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
  }

  assert {
    condition     = azurerm_network_security_group.main.name == "webapp-nsg"
    error_message = "NSG name should follow pattern: {prefix}-nsg"
  }
}

# =============================================================================
# Test: VNet and subnet naming convention
# =============================================================================
run "network_naming_convention" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    prefix                  = "api"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
  }

  assert {
    condition     = azurerm_virtual_network.main.name == "api-vnet"
    error_message = "VNet name should follow pattern: {prefix}-vnet"
  }

  assert {
    condition     = azurerm_subnet.main.name == "api-subnet"
    error_message = "Subnet name should follow pattern: {prefix}-subnet"
  }
}

# =============================================================================
# Test: Resource names are lowercase
# =============================================================================
run "resource_names_lowercase" {
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
    condition     = azurerm_virtual_network.main.name == lower(azurerm_virtual_network.main.name)
    error_message = "VNet name should be lowercase"
  }

  assert {
    condition     = azurerm_subnet.main.name == lower(azurerm_subnet.main.name)
    error_message = "Subnet name should be lowercase"
  }
}

# =============================================================================
# Test: VM names can be customized
# =============================================================================
run "vm_name_customization" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    name                    = "custom-webserver-01"
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
    subnet_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
    security_group_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/networkSecurityGroups/nsg"
    ssh_public_key_path     = "./tests/fixtures/test_ssh_key.pub"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.main.name == "custom-webserver-01"
    error_message = "VM name should match the provided custom name"
  }
}
