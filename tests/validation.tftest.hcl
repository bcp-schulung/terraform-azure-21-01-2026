# Terraform Validation Tests
# These tests verify configuration validation without requiring Azure access
# Run with: terraform test

mock_provider "azurerm" {}

# Override the data source to mock the resource group
override_data {
  target = data.azurerm_resource_group.lab
  values = {
    name     = "rg-tf-lab"
    location = "Germany West Central"
  }
}

# =============================================================================
# Test: Required variables validation
# =============================================================================
run "validate_prefix_required" {
  command = plan

  variables {
    prefix              = "myapp"
    resource_group_name = "rg-tf-lab"
  }

  assert {
    condition     = var.prefix == "myapp"
    error_message = "Prefix should be set to 'myapp'"
  }
}

# =============================================================================
# Test: Default values are correctly applied
# =============================================================================
run "validate_default_values" {
  command = plan

  variables {
    prefix              = "test"
    resource_group_name = "rg-tf-lab"
  }

  assert {
    condition     = var.vm_size == "Standard_B2s"
    error_message = "Default VM size should be 'Standard_B2s'"
  }

  assert {
    condition     = var.admin_username == "azureuser"
    error_message = "Default admin username should be 'azureuser'"
  }

  assert {
    condition     = var.location == "Germany West Central"
    error_message = "Default location should be 'Germany West Central'"
  }
}

# =============================================================================
# Test: Tags default values
# =============================================================================
run "validate_default_tags" {
  command = plan

  variables {
    prefix              = "test"
    resource_group_name = "rg-tf-lab"
  }

  assert {
    condition     = var.tags["Environment"] == "Development"
    error_message = "Default Environment tag should be 'Development'"
  }

  assert {
    condition     = var.tags["Project"] == "TerraformAzureVM"
    error_message = "Default Project tag should be 'TerraformAzureVM'"
  }
}

# =============================================================================
# Test: Image configuration defaults
# =============================================================================
run "validate_image_defaults" {
  command = plan

  variables {
    prefix              = "test"
    resource_group_name = "rg-tf-lab"
  }

  assert {
    condition     = var.source_manager_publisher == "Canonical"
    error_message = "Default image publisher should be 'Canonical'"
  }

  assert {
    condition     = var.source_manager_offer == "0001-com-ubuntu-server-jammy"
    error_message = "Default image offer should be Ubuntu Jammy"
  }

  assert {
    condition     = var.source_manager_sku == "22_04-lts"
    error_message = "Default image SKU should be '22_04-lts'"
  }

  assert {
    condition     = var.source_manager_version == "latest"
    error_message = "Default image version should be 'latest'"
  }
}

# =============================================================================
# Test: Custom variable values work correctly
# =============================================================================
run "validate_custom_values" {
  command = plan

  variables {
    prefix              = "prod"
    resource_group_name = "rg-production"
    vm_size             = "Standard_D2s_v3"
    admin_username      = "prodadmin"
    location            = "West Europe"
    tags = {
      Environment = "Production"
      Project     = "CriticalApp"
      CostCenter  = "IT-001"
    }
  }

  assert {
    condition     = var.prefix == "prod"
    error_message = "Custom prefix should be 'prod'"
  }

  assert {
    condition     = var.vm_size == "Standard_D2s_v3"
    error_message = "Custom VM size should be 'Standard_D2s_v3'"
  }

  assert {
    condition     = var.admin_username == "prodadmin"
    error_message = "Custom admin username should be 'prodadmin'"
  }

  assert {
    condition     = var.tags["CostCenter"] == "IT-001"
    error_message = "Custom CostCenter tag should be 'IT-001'"
  }
}
