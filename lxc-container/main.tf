locals {
  network_ip_cidr = var.network_ip == "dhcp" ? var.network_ip : "${var.network_ip}/24"
}
resource "proxmox_lxc" "lxc-container" {
  vmid         = var.vmid
  target_node  = var.target_node
  hostname     = var.hostname
  ostemplate   = var.ostemplate
  password     = var.password
  unprivileged = var.unprivileged

  memory = var.memory
  start  = var.start

  features {
    nesting = var.nesting
  }

  ssh_public_keys = var.ssh_public_keys

  // Terraform will crash without rootfs defined
  rootfs {
    storage = var.rootfs_storage
    size    = var.rootfs_size
  }

  network {
    name   = var.network_name
    bridge = var.network_bridge
    ip     = local.network_ip_cidr
    gw     = var.network_gw
  }

  tags = var.tags
}

output "ipv4" {
  description = "The default IPv4 address of the container."
  value       = var.network_ip == "dhcp" ? "-" : var.network_ip
}

output "username" {
  description = "The default username for the container."
  value       = "root"
}

output "vmid" {
  description = "value"
  value       = var.vmid
}