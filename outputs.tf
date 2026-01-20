output "vm_name" {
  description = "Name of the virtual machine"
  value       = module.vm[*].name
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = module.vm[*].ssh_command
}
