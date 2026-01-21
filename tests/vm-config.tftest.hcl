# VM Size and Configuration Tests
# Validates VM sizing, image selection, and configuration

mock_provider "azurerm" {}

# =============================================================================
# Test: Default VM size is appropriate for development
# =============================================================================
run "default_vm_size" {
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
    condition     = azurerm_linux_virtual_machine.main.size == "Standard_B2s"
    error_message = "Default VM size should be Standard_B2s for development"
  }
}

# =============================================================================
# Test: VM size can be customized
# =============================================================================
run "custom_vm_size" {
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
    vm_size                 = "Standard_D4s_v3"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.main.size == "Standard_D4s_v3"
    error_message = "VM size should be customizable to Standard_D4s_v3"
  }
}

# =============================================================================
# Test: VM uses Ubuntu LTS image
# =============================================================================
run "vm_uses_ubuntu_lts" {
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
    condition     = azurerm_linux_virtual_machine.main.source_image_reference[0].publisher == "Canonical"
    error_message = "VM should use Canonical (Ubuntu) publisher"
  }

  assert {
    condition     = can(regex("lts", azurerm_linux_virtual_machine.main.source_image_reference[0].sku))
    error_message = "VM should use LTS version of Ubuntu"
  }
}

# =============================================================================
# Test: VM uses Ubuntu 22.04 (Jammy)
# =============================================================================
run "vm_uses_ubuntu_jammy" {
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
    condition     = azurerm_linux_virtual_machine.main.source_image_reference[0].offer == "0001-com-ubuntu-server-jammy"
    error_message = "VM should use Ubuntu Jammy (22.04) server offer"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.main.source_image_reference[0].sku == "22_04-lts"
    error_message = "VM should use Ubuntu 22.04 LTS SKU"
  }
}

# =============================================================================
# Test: Admin username is configurable
# =============================================================================
run "admin_username_configurable" {
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
    admin_username          = "customadmin"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.main.admin_username == "customadmin"
    error_message = "Admin username should be customizable"
  }
}

# =============================================================================
# Test: OS disk uses ReadWrite caching
# =============================================================================
run "os_disk_caching" {
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
    condition     = azurerm_linux_virtual_machine.main.os_disk[0].caching == "ReadWrite"
    error_message = "OS disk should use ReadWrite caching"
  }
}

# =============================================================================
# Test: VM has exactly one network interface
# =============================================================================
run "vm_single_nic" {
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
    condition     = length(azurerm_linux_virtual_machine.main.network_interface_ids) == 1
    error_message = "VM should have exactly one network interface"
  }
}
