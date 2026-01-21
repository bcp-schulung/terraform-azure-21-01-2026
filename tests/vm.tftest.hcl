# Terraform Tests for VM Module
# Run with: terraform test

mock_provider "azurerm" {}

# Mock the SSH key file function
override_module {
  target = module.vm
  outputs = {
    name        = "test-vm"
    ssh_command = "ssh azureuser@1.2.3.4"
  }
}

# =============================================================================
# Test: VM module creates expected resources
# =============================================================================
run "vm_module_plan" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    name                    = "test-vm"
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
    subnet_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tf-lab/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    security_group_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tf-lab/providers/Microsoft.Network/networkSecurityGroups/test-nsg"
    ssh_public_key_path     = "./tests/fixtures/test_ssh_key.pub"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.main.name == "test-vm"
    error_message = "VM name should be 'test-vm'"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.main.size == "Standard_B2s"
    error_message = "VM size should be 'Standard_B2s'"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.main.admin_username == "azureuser"
    error_message = "Admin username should be 'azureuser'"
  }
}

# =============================================================================
# Test: VM creates Public IP with correct settings
# =============================================================================
run "vm_public_ip_settings" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    name                    = "test-vm"
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
    subnet_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tf-lab/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    security_group_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tf-lab/providers/Microsoft.Network/networkSecurityGroups/test-nsg"
    ssh_public_key_path     = "./tests/fixtures/test_ssh_key.pub"
  }

  assert {
    condition     = azurerm_public_ip.main.name == "test-pip"
    error_message = "Public IP name should be 'test-pip'"
  }

  assert {
    condition     = azurerm_public_ip.main.allocation_method == "Static"
    error_message = "Public IP should use static allocation"
  }

  assert {
    condition     = azurerm_public_ip.main.sku == "Standard"
    error_message = "Public IP should use Standard SKU"
  }
}

# =============================================================================
# Test: VM creates Network Interface with correct settings
# =============================================================================
run "vm_network_interface_settings" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    name                    = "test-vm"
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
    subnet_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tf-lab/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    security_group_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tf-lab/providers/Microsoft.Network/networkSecurityGroups/test-nsg"
    ssh_public_key_path     = "./tests/fixtures/test_ssh_key.pub"
  }

  assert {
    condition     = azurerm_network_interface.main.name == "test-nic"
    error_message = "Network interface name should be 'test-nic'"
  }

  assert {
    condition     = azurerm_network_interface.main.ip_configuration[0].name == "internal"
    error_message = "IP configuration name should be 'internal'"
  }

  assert {
    condition     = azurerm_network_interface.main.ip_configuration[0].private_ip_address_allocation == "Dynamic"
    error_message = "Private IP allocation should be Dynamic"
  }
}

# =============================================================================
# Test: VM OS disk configuration
# =============================================================================
run "vm_os_disk_settings" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    name                    = "test-vm"
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
    subnet_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tf-lab/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    security_group_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tf-lab/providers/Microsoft.Network/networkSecurityGroups/test-nsg"
    ssh_public_key_path     = "./tests/fixtures/test_ssh_key.pub"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.main.os_disk[0].caching == "ReadWrite"
    error_message = "OS disk caching should be 'ReadWrite'"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.main.os_disk[0].storage_account_type == "Standard_LRS"
    error_message = "OS disk storage type should be 'Standard_LRS'"
  }
}

# =============================================================================
# Test: VM source image configuration (Ubuntu)
# =============================================================================
run "vm_source_image" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    name                    = "test-vm"
    prefix                  = "test"
    resource_group_name     = "rg-tf-lab"
    resource_group_location = "Germany West Central"
    subnet_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tf-lab/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    security_group_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tf-lab/providers/Microsoft.Network/networkSecurityGroups/test-nsg"
    ssh_public_key_path     = "./tests/fixtures/test_ssh_key.pub"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.main.source_image_reference[0].publisher == "Canonical"
    error_message = "Image publisher should be 'Canonical'"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.main.source_image_reference[0].offer == "0001-com-ubuntu-server-jammy"
    error_message = "Image offer should be Ubuntu Jammy"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.main.source_image_reference[0].sku == "22_04-lts"
    error_message = "Image SKU should be '22_04-lts'"
  }
}
