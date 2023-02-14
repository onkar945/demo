output "admin_ssh_key_public" {
  description = "The generated public key data in PEM format"
  value       = var.disable_password_authentication == true && var.generate_admin_ssh_key == true && var.os_flavor == "linux" ? tls_private_key.rsa[0].public_key_openssh : null
}

output "admin_ssh_key_private" {
  description = "The generated private key data in PEM format"
  sensitive   = true
  value       = var.disable_password_authentication == true && var.generate_admin_ssh_key == true && var.os_flavor == "linux" ? tls_private_key.rsa[0].private_key_pem : null
}

output "linux_vm_password" {
  description = "Password for the Linux VM"
  sensitive   = true
  value       = var.disable_password_authentication == false && var.admin_password == null ? element(concat(random_password.passwd.*.result, [""]), 0) : var.admin_password
}

output "linux_virtual_machine_ids" {
  description = "The resource id's of all Linux Virtual Machine."
  value       = var.os_flavor == "linux" ? concat(azurerm_linux_virtual_machine.linux_vm.*.id, [""]) : null
}

output "linux_vm_nic_ids" {
  description = "The NIC id's of all Linux Virtual Machine."
  value       = var.os_flavor == "linux" ? concat(azurerm_network_interface.nic.*.id, [""]) : null
}

output "linux_virtual_machine_ips" {
  description = "The private ip's of all Linux Virtual Machine."
  value       = var.os_flavor == "linux" ? concat(azurerm_linux_virtual_machine.linux_vm.*.private_ip_address, [""]) : null
}