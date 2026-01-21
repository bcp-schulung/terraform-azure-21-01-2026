variable "prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "schulung"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-tf-lab"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "Germany West Central"
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "TerraformAzureVM"


  }
}

variable "source_manager_publisher" {
  description = "publisher"
  type        = string
  default     = "Canonical"
}

variable "source_manager_offer" {
  description = "offer"
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "source_manager_sku" {
  description = "sku"
  type        = string
  default     = "22_04-lts"
}

variable "source_manager_version" {
  description = "version"
  type        = string
  default     = "latest"
}