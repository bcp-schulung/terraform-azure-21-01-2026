# Network Configuration Tests
# Validates network-specific configurations and CIDR calculations

mock_provider "azurerm" {}

# =============================================================================
# Test: VNet has valid CIDR block
# =============================================================================
run "vnet_valid_cidr" {
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
    condition     = azurerm_virtual_network.main.address_space[0] == "10.0.0.0/16"
    error_message = "VNet should use 10.0.0.0/16 CIDR block"
  }
}

# =============================================================================
# Test: Subnet CIDR is smaller than VNet CIDR
# =============================================================================
run "subnet_cidr_smaller_than_vnet" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
  }

  # VNet is /16, subnet should be smaller (larger number = smaller network)
  assert {
    condition     = azurerm_subnet.main.address_prefixes[0] == "10.0.1.0/24"
    error_message = "Subnet should use /24 which is smaller than VNet /16"
  }
}

# =============================================================================
# Test: Subnet is within VNet address range
# =============================================================================
run "subnet_within_vnet_address_range" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
  }

  # Subnet 10.0.1.0/24 should be within VNet 10.0.0.0/16
  assert {
    condition     = startswith(azurerm_subnet.main.address_prefixes[0], "10.0.")
    error_message = "Subnet must be within VNet 10.0.0.0/16 address space"
  }
}

# =============================================================================
# Test: NIC uses dynamic private IP allocation
# =============================================================================
run "nic_dynamic_private_ip" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    name                    = "test-vm"
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
    subnet_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
    security_group_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/networkSecurityGroups/nsg"
    ssh_public_key_path     = "./tests/fixtures/test_ssh_key.pub"
  }

  assert {
    condition     = azurerm_network_interface.main.ip_configuration[0].private_ip_address_allocation == "Dynamic"
    error_message = "NIC should use Dynamic private IP allocation"
  }
}

# =============================================================================
# Test: NIC IP configuration is named correctly
# =============================================================================
run "nic_ip_config_name" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    name                    = "test-vm"
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
    subnet_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
    security_group_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/networkSecurityGroups/nsg"
    ssh_public_key_path     = "./tests/fixtures/test_ssh_key.pub"
  }

  assert {
    condition     = azurerm_network_interface.main.ip_configuration[0].name == "internal"
    error_message = "NIC IP configuration should be named 'internal'"
  }
}

# =============================================================================
# Test: Subnet is associated with correct VNet
# =============================================================================
run "subnet_vnet_association" {
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
    condition     = azurerm_subnet.main.virtual_network_name == azurerm_virtual_network.main.name
    error_message = "Subnet must be associated with the created VNet"
  }
}
