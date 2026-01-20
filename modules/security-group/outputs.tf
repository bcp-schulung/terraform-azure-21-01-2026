output "security_group_id" {
  description = "The Network Security Group ID"
  value       = azurerm_network_security_group.main.id
}