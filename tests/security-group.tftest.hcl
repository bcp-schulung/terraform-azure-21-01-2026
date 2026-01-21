# Terraform Tests for Security Group Module
# Run with: terraform test

mock_provider "azurerm" {}

# =============================================================================
# Test: Security group module creates NSG with SSH rule
# =============================================================================
run "security_group_plan" {
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
    condition     = azurerm_network_security_group.main.name == "test-nsg"
    error_message = "NSG name should be 'test-nsg'"
  }

  assert {
    condition     = length(azurerm_network_security_group.main.security_rule) > 0
    error_message = "NSG should have at least one security rule"
  }
}

# =============================================================================
# Test: Security group has SSH rule configured correctly
# =============================================================================
run "security_group_ssh_rule" {
  command = plan

  module {
    source = "./modules/security-group"
  }

  variables {
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
  }

  # Use anytrue/alltrue to check set elements since security_rule is a set, not a list
  assert {
    condition     = anytrue([for rule in azurerm_network_security_group.main.security_rule : rule.name == "SSH"])
    error_message = "NSG should have a rule named 'SSH'"
  }

  assert {
    condition     = anytrue([for rule in azurerm_network_security_group.main.security_rule : rule.destination_port_range == "22"])
    error_message = "SSH rule should target port 22"
  }

  assert {
    condition     = anytrue([for rule in azurerm_network_security_group.main.security_rule : rule.protocol == "Tcp"])
    error_message = "SSH rule should use TCP protocol"
  }

  assert {
    condition     = anytrue([for rule in azurerm_network_security_group.main.security_rule : rule.direction == "Inbound"])
    error_message = "SSH rule should be inbound"
  }

  assert {
    condition     = anytrue([for rule in azurerm_network_security_group.main.security_rule : rule.access == "Allow"])
    error_message = "SSH rule should allow traffic"
  }

  assert {
    condition     = anytrue([for rule in azurerm_network_security_group.main.security_rule : rule.priority == 1001])
    error_message = "SSH rule priority should be 1001"
  }
}

# =============================================================================
# Test: Security group uses correct resource group
# =============================================================================
run "security_group_resource_group" {
  command = plan

  module {
    source = "./modules/security-group"
  }

  variables {
    prefix                  = "prod"
    resource_group_name     = "rg-production"
    resource_group_location = "East US"
  }

  assert {
    condition     = azurerm_network_security_group.main.resource_group_name == "rg-production"
    error_message = "NSG should be in 'rg-production' resource group"
  }

  assert {
    condition     = azurerm_network_security_group.main.location == "East US"
    error_message = "NSG location should be 'East US'"
  }
}
