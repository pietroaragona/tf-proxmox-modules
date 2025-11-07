output "ipv4" {
  description = "The default IPv4 address of the virtual machine."
  value       = proxmox_vm_qemu.vm.default_ipv4_address
}

output "username" {
  description = "The default username for the virtual machine."
  value = proxmox_vm_qemu.vm.ciuser
}