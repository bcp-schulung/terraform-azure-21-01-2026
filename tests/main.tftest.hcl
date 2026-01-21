# Terraform Test File for Azure Infrastructure
# Run with: terraform test

# Mock the Azure provider to avoid requiring real credentials for plan tests
mock_provider "azurerm" {}

# Variables to use across all tests
variables {
  prefix              = "test"
  resource_group_name = "rg-tf-lab"
  location            = "Germany West Central"
  vm_size             = "Standard_B2s"
  admin_username      = "azureuser"
}

# Override the data source to mock the resource group
override_data {
  target = data.azurerm_resource_group.lab
  values = {
    name     = "rg-tf-lab"
    location = "Germany West Central"
  }
}

# =============================================================================
# Test: Validate that the infrastructure plans successfully
# =============================================================================
run "validate_plan_succeeds" {
  command = plan

  assert {
    condition     = length(module.vm) == 2
    error_message = "Expected 2 VMs to be created"
  }

  assert {
    condition     = module.network != null
    error_message = "Network module should be created"
  }

  assert {
    condition     = module.security-group != null
    error_message = "Security group module should be created"
  }
}

# =============================================================================
# Test: Validate VM module creates expected resources
# =============================================================================
run "validate_vm_resources" {
  command = plan

  assert {
    condition     = module.vm[0].name == "test-vm1"
    error_message = "First VM should be named 'test-vm1'"
  }

  assert {
    condition     = module.vm[1].name == "test-vm2"
    error_message = "Second VM should be named 'test-vm2'"
  }
}

# =============================================================================
# Test: Validate outputs are generated correctly
# =============================================================================
run "validate_outputs" {
  command = plan

  assert {
    condition     = length(output.vm_name) == 2
    error_message = "Expected 2 VM names in output"
  }

  assert {
    condition     = length(output.ssh_command) == 2
    error_message = "Expected 2 SSH commands in output"
  }
}
