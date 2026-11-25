output "ipv4" {
  description = "The default IPv4 addresses of the virtual machines."
  value       = [for vm in proxmox_vm_qemu.vm : vm.default_ipv4_address]
}

output "username" {
  description = "The default usernames for the virtual machines."
  value       = [for vm in proxmox_vm_qemu.vm : vm.ciuser]
}

output "name" {
  description = "The names of the virtual machines."
  value       = [for vm in proxmox_vm_qemu.vm : vm.name]
}

output "vms" {
  description = "Virtual machine details ordered by creation index."
  value = [
    for idx, vm in proxmox_vm_qemu.vm : {
      index    = idx + 1
      vmid     = var.vmid + idx
      name     = vm.name
      username = vm.ciuser
      ipv4     = vm.default_ipv4_address
    }
  ]
}