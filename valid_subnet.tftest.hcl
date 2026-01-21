mock_provider "azurerm" {}

run "valid_subnet" {
    variables {
    prefix = "test"
    resource_group_location = "Germany West Central"
    resource_group_name = "rg-tf-lab"
    }
    command = plan 
    module {
        source = "./modules/network"
        }
    assert{
        condition = azurerm_subnet.main.name == "test-subnet"
        error_message = "das Subnet konnte nicht erstellt werden"
    }
}

