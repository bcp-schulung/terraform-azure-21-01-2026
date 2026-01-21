# Create a Public IP
resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-pip"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}
# Create a Network Interface
resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = var.security_group_id
}


data "azurerm_key_vault" "kv" {
  name                = "testtest123test"
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "mysecret" {
  name         = "publickey"
  key_vault_id = data.azurerm_key_vault.kv.id
}

# Create the Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.main.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = data.azurerm_key_vault_secret.mysecret.value
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.source_manager_publisher
    offer     = var.source_manager_offer
    sku       = var.source_manager_sku
    version   = var.source_manager_version
  }

  tags = var.tags
}