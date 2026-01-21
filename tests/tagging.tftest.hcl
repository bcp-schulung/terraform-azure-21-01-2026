# Tagging Compliance Tests
# Ensures all resources have required tags for governance and cost management

mock_provider "azurerm" {}

# =============================================================================
# Test: Network resources have tags
# =============================================================================
run "network_resources_have_tags" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
    tags = {
      Environment = "Test"
      Project     = "TerraformAzureVM"
      Owner       = "DevOps"
    }
  }

  assert {
    condition     = azurerm_virtual_network.main.tags != null
    error_message = "Virtual Network must have tags"
  }

  assert {
    condition     = azurerm_virtual_network.main.tags["Environment"] == "Test"
    error_message = "Virtual Network must have Environment tag"
  }

  assert {
    condition     = azurerm_virtual_network.main.tags["Project"] == "TerraformAzureVM"
    error_message = "Virtual Network must have Project tag"
  }
}

# =============================================================================
# Test: Security group resources have tags
# =============================================================================
run "security_group_has_tags" {
  command = plan

  module {
    source = "./modules/security-group"
  }

  variables {
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
    tags = {
      Environment = "Production"
      CostCenter  = "IT-001"
    }
  }

  assert {
    condition     = azurerm_network_security_group.main.tags != null
    error_message = "NSG must have tags"
  }

  assert {
    condition     = azurerm_network_security_group.main.tags["Environment"] == "Production"
    error_message = "NSG must have correct Environment tag"
  }

  assert {
    condition     = azurerm_network_security_group.main.tags["CostCenter"] == "IT-001"
    error_message = "NSG must have CostCenter tag for billing"
  }
}

# =============================================================================
# Test: VM resources have tags
# =============================================================================
run "vm_resources_have_tags" {
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
    tags = {
      Environment = "Development"
      Project     = "TerraformAzureVM"
      Application = "WebServer"
    }
  }

  assert {
    condition     = azurerm_linux_virtual_machine.main.tags != null
    error_message = "VM must have tags"
  }

  assert {
    condition     = azurerm_public_ip.main.tags != null
    error_message = "Public IP must have tags"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.main.tags["Application"] == "WebServer"
    error_message = "VM must have Application tag"
  }
}

# =============================================================================
# Test: Default tags are applied when not specified
# =============================================================================
run "default_tags_applied" {
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

  # Default tags should include Environment and Project
  assert {
    condition     = azurerm_linux_virtual_machine.main.tags["Environment"] == "Development"
    error_message = "Default Environment tag should be 'Development'"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.main.tags["Project"] == "TerraformAzureVM"
    error_message = "Default Project tag should be 'TerraformAzureVM'"
  }
}
