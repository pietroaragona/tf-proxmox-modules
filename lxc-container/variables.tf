variable "vmid" {
  description = "The LXC container ID"
  type        = number
}

variable "target_node" {
  description = "The Proxmox node name"
  type        = string
}

variable "hostname" {
  description = "The LXC container hostname"
  type        = string
}

variable "ostemplate" {
  description = "The OS template to use (e.g., local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst)"
  type        = string
}

variable "password" {
  description = "The root password for the container"
  type        = string
  sensitive   = true
}

variable "unprivileged" {
  description = "Whether the container is unprivileged"
  type        = bool
  default     = true
}

variable "memory" {
  description = "The amount of memory in MB"
  type        = number
  default     = 768
}

variable "start" {
  description = "Whether to start the container after creation"
  type        = bool
  default     = true
}

variable "rootfs_storage" {
  description = "The storage location for rootfs"
  type        = string
  default     = "local-lvm"
}

variable "rootfs_size" {
  description = "The size of the rootfs"
  type        = string
  default     = "4G"
}

variable "network_name" {
  description = "The network interface name"
  type        = string
  default     = "eth0"
}

variable "network_bridge" {
  description = "The network bridge"
  type        = string
  default     = "vmbr0"
}

variable "network_ip" {
  description = "The IP configuration (e.g., dhcp or 192.168.1.10/24)"
  type        = string
  default     = "dhcp"
}

variable "network_gw" {
  description = "Gateway IP address for the container network"
  type        = string
  default     = "192.168.1.1"
}

variable "tags" {
  description = "Tags to apply to the container"
  type        = string
  default     = "tf-managed"
}

variable "ssh_public_keys" {
  description = "List of SSH public keys to add to the container"
  type        = string
  default     = ""
}

variable "nesting" {
  description = "Enable nesting feature (required for Docker, Tailscale, etc.)"
  type        = bool
  default     = true
}