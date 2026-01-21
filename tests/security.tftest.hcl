# Security and Compliance Tests
# Validates security best practices and compliance requirements

mock_provider "azurerm" {}

# =============================================================================
# Test: Public IP uses Standard SKU (required for availability zones)
# =============================================================================
run "public_ip_uses_standard_sku" {
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
    condition     = azurerm_public_ip.main.sku == "Standard"
    error_message = "Public IP must use Standard SKU for production workloads"
  }

  assert {
    condition     = azurerm_public_ip.main.allocation_method == "Static"
    error_message = "Standard SKU Public IPs must use Static allocation"
  }
}

# =============================================================================
# Test: VM uses SSH key authentication (no password)
# =============================================================================
run "vm_uses_ssh_key_auth" {
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
    condition     = length(azurerm_linux_virtual_machine.main.admin_ssh_key) > 0
    error_message = "VM must use SSH key authentication"
  }

  assert {
    condition     = anytrue([for key in azurerm_linux_virtual_machine.main.admin_ssh_key : key.username == "azureuser"])
    error_message = "SSH key must be associated with the admin user"
  }
}

# =============================================================================
# Test: NSG restricts SSH to specific port
# =============================================================================
run "nsg_ssh_port_restriction" {
  command = plan

  module {
    source = "./modules/security-group"
  }

  variables {
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
  }

  assert {
    condition     = anytrue([for rule in azurerm_network_security_group.main.security_rule : rule.destination_port_range == "22"])
    error_message = "SSH rule must only allow port 22"
  }

  assert {
    condition     = anytrue([for rule in azurerm_network_security_group.main.security_rule : rule.protocol == "Tcp"])
    error_message = "SSH rule must use TCP protocol only"
  }
}

# =============================================================================
# Test: Network interface is associated with NSG
# =============================================================================
run "nic_has_nsg_association" {
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
    condition     = azurerm_network_interface_security_group_association.main != null
    error_message = "Network interface must have NSG association"
  }
}

# =============================================================================
# Test: OS disk uses appropriate storage type
# =============================================================================
run "os_disk_storage_type" {
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
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], azurerm_linux_virtual_machine.main.os_disk[0].storage_account_type)
    error_message = "OS disk must use a valid storage account type"
  }
}

# =============================================================================
# Test: VNet uses private address space (RFC 1918)
# =============================================================================
run "vnet_uses_private_address_space" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
  }

  # Check that address space starts with 10., 172.16-31., or 192.168.
  assert {
    condition     = can(regex("^(10\\.|172\\.(1[6-9]|2[0-9]|3[0-1])\\.|192\\.168\\.)", azurerm_virtual_network.main.address_space[0]))
    error_message = "VNet must use RFC 1918 private address space (10.x, 172.16-31.x, or 192.168.x)"
  }
}

# =============================================================================
# Test: Subnet is within VNet address space
# =============================================================================
run "subnet_within_vnet_range" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
  }

  # Both should be in 10.0.x.x range
  assert {
    condition     = startswith(azurerm_subnet.main.address_prefixes[0], "10.0.")
    error_message = "Subnet address must be within VNet address space (10.0.x.x)"
  }
}
