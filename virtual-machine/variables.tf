
variable "vmid" {
  description = "The VM ID."
  type        = number
}

variable "vm_name" {
  description = "The VM name"
  type        = string
}

variable "pm_tls_insecure" {
  description = "Set to true to ignore certificate errors"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to assign to the VM"
  type        = string
  default     = "tf-managed"
}

variable "vm_state" {
  description = "The desired state of the VM (e.g., 'started', 'stopped')"
  type        = string
  default     = "started"
}

variable "force_create" {
  description = "If true and VM with same name/vmid exists, force creation/recycle behavior in provider."
  type        = bool
  default     = false
}

#Establish which Proxmox host you'd like to spin a VM up on
variable "proxmox_host" {
  description = "The Proxmox host to deploy the VM on"
  type        = string
}

variable "agent" {
  description = "Activate QEMU agent for this VM"
  type        = number
  default     = 1
}
#Specify which template name you'd like to use
variable "template_name" {
  description = "Specify which template name you'd like to use"
  type        = string
}
#Establish which nic you would like to utilize
variable "nic_name" {
  description = "The network interface card name."
  default     = "vmbr0"
}

# Number of VMs to spin up
variable "vm_count" {
  default = 1
}

# Needed for remote exec
variable "ssh_keys" {
  description = "SSH public keys for cloud-init user."
  type        = string
  #   default = <<EOF
  # ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDjuXJsm20610XQGaGgsagEupVlfzYMorJXrNo1u7Gx took@oscar
  # ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGFq+qHtrX9QBM1P8aKmFzPq8CiBi0oWlVCPR3Q0Y9Th cpete0624@C02G66FNMD6R
  # ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFvTxWlvvqFcVFSfCCTfmC61Z7Dzkuk0t5s8dos4/Bb took@brook
  # EOF
}

variable "cipassword" {
  description = "The password for the cloud-init user."
  type        = string
  sensitive   = true
}

variable "os_type" {
  description = "The operating system type for the VM."
  type        = string
  default     = "cloud-init"
}

variable "ciuser" {
  description = "The cloud-init user."
  type        = string
}

variable "ciupgrade" {
  description = "Upgrade the packages on the guest during provisioning"
  type        = bool
  default     = true
}

variable "ipconfig0" {
  description = "IP configuration for the VM."
  type        = string
}

variable "skip_ipv6" {
  description = "Skip IPv6 configuration."
  type        = bool
  default     = true
}

variable "cpu_cores" {
  description = "Number of CPU cores."
  type        = number
  default     = 2
}

variable "cpu_sockets" {
  description = "Number of CPU sockets."
  type        = number
  default     = 1
}

variable "cpu_vcores" {
  description = "Number of virtual cores."
  type        = number
  default     = 0
}

variable "cpu_type" {
  description = "CPU type."
  type        = string
  default     = "host"
}

variable "memory" {
  description = "Amount of memory in MB."
  type        = number
  default     = 2048
}

variable "scsihw" {
  description = "SCSI hardware type."
  type        = string
  default     = "virtio-scsi-single"
}

variable "serial_id" {
  description = "Serial device ID."
  type        = number
  default     = 0
}

variable "disk_storage" {
  description = "Storage for the disk."
  type        = string
  default     = "local-lvm"
}

variable "disk_size" {
  description = "Disk size."
  type        = string
  default     = "5G"
}

variable "emulatessd" {
  description = "value"
  type        = bool
  default     = true
}

variable "cloudinit_storage" {
  description = "Storage for the cloud-init disk."
  type        = string
  default     = "local-lvm"
}

variable "extra_disks" {
  description = <<-EOT
    Additional SCSI disks to attach to the VM.
    Example:
    [
      {
        slot    = "scsi1"
        storage = "local-lvm"
        size    = "10G"
      }
    ]
  EOT

  type = list(object({
    slot    = string
    storage = string
    size    = string
  }))

  default = []

  validation {
    condition = alltrue([
      for disk in var.extra_disks : can(regex("^(ide[0-3]|sata[0-5]|scsi([1-9]|[1-2][0-9]|30)|virtio([0-9]|1[0-5]))$", disk.slot))
    ])
    error_message = "Each extra disk slot must be a valid non-reserved slot, for example scsi1, scsi2, sata0 or virtio1. Reserved slots ide1 and scsi0 cannot be used."
  }

  validation {
    condition     = length(distinct([for disk in var.extra_disks : disk.slot])) == length(var.extra_disks)
    error_message = "Each extra disk must use a unique slot."
  }
}

variable "extra_disk_cache" {
  description = "Cache mode to use for extra disks."
  type        = string
  default     = "none"
}

variable "extra_disk_iothread" {
  description = "Whether to enable iothread for extra disks."
  type        = bool
  default     = true
}

variable "extra_disk_discard" {
  description = "Whether to enable discard for extra disks."
  type        = bool
  default     = false
}

variable "extra_disk_emulatessd" {
  description = "Whether to expose extra disks as SSDs."
  type        = bool
  default     = false
}

variable "network_id" {
  description = "Network device ID."
  type        = number
  default     = 0
}

variable "network_bridge" {
  description = "Network bridge."
  type        = string
  default     = "vmbr0"
}

variable "network_model" {
  description = "Network model."
  type        = string
  default     = "virtio"
}