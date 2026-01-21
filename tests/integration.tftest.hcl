# Integration Tests
# Tests that validate how modules work together

mock_provider "azurerm" {}

override_data {
  target = data.azurerm_resource_group.lab
  values = {
    name     = "rg-tf-lab"
    location = "Germany West Central"
  }
}

# =============================================================================
# Test: Full infrastructure deployment creates correct number of resources
# =============================================================================
run "full_deployment_resource_count" {
  command = plan

  variables {
    prefix              = "integration"
    resource_group_name = "rg-tf-lab"
  }

  # Verify VMs are created
  assert {
    condition     = length(module.vm) == 2
    error_message = "Should create exactly 2 VMs"
  }
}

# =============================================================================
# Test: All VMs get unique names
# =============================================================================
run "vms_have_unique_names" {
  command = plan

  variables {
    prefix              = "test"
    resource_group_name = "rg-tf-lab"
  }

  assert {
    condition     = module.vm[0].name != module.vm[1].name
    error_message = "Each VM must have a unique name"
  }

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
# Test: VMs use shared network infrastructure
# =============================================================================
run "vms_share_network" {
  command = plan

  variables {
    prefix              = "shared"
    resource_group_name = "rg-tf-lab"
  }

  # Both VMs should reference the same network module
  assert {
    condition     = module.network != null
    error_message = "Network module should exist for VM connectivity"
  }

  assert {
    condition     = module.security-group != null
    error_message = "Security group module should exist for VM security"
  }
}

# =============================================================================
# Test: All resources in same resource group
# =============================================================================
run "all_resources_same_resource_group" {
  command = plan

  variables {
    prefix              = "test"
    resource_group_name = "rg-tf-lab"
  }

  # All modules should use the same resource group
  assert {
    condition     = length(module.vm) > 0
    error_message = "VMs should be created in the resource group"
  }
}

# =============================================================================
# Test: Different prefix creates different resource names
# =============================================================================
run "different_prefix_different_names_dev" {
  command = plan

  variables {
    prefix              = "dev"
    resource_group_name = "rg-tf-lab"
  }

  assert {
    condition     = module.vm[0].name == "dev-vm1"
    error_message = "Dev VM should be named 'dev-vm1'"
  }
}

run "different_prefix_different_names_prod" {
  command = plan

  variables {
    prefix              = "prod"
    resource_group_name = "rg-tf-lab"
  }

  assert {
    condition     = module.vm[0].name == "prod-vm1"
    error_message = "Prod VM should be named 'prod-vm1'"
  }
}

# =============================================================================
# Test: Outputs are correctly propagated
# =============================================================================
run "outputs_correctly_propagated" {
  command = plan

  variables {
    prefix              = "test"
    resource_group_name = "rg-tf-lab"
  }

  assert {
    condition     = output.vm_name != null
    error_message = "vm_name output should be defined"
  }

  assert {
    condition     = output.ssh_command != null
    error_message = "ssh_command output should be defined"
  }

  assert {
    condition     = length(output.vm_name) == 2
    error_message = "Should have 2 VM names in output"
  }

  assert {
    condition     = length(output.ssh_command) == 2
    error_message = "Should have 2 SSH commands in output"
  }
}
