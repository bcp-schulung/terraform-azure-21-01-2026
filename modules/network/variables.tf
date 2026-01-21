variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "TerraformAzureVM"
  }
}

variable "prefix" {
  description = "Prefix for all resource names"
  type        = string
  default = "schulung"

  validation {
    condition = var.prefix != "test"
    error_message = "Prefix not correct"
  }
}

variable "resource_group_location" {
  description = "name of the resource group location"
  type = string
  
}
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}