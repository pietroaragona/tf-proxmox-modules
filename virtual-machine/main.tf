locals {
  extra_disks_by_slot = {
    for disk in var.extra_disks : disk.slot => disk
  }
}

resource "proxmox_vm_qemu" "vm" {
  vmid        = var.vmid
  name        = var.vm_name
  target_node = var.proxmox_host
  tags        = var.tags
  vm_state    = var.vm_state
  force_create = var.force_create

  clone = var.template_name

  agent = var.agent

  os_type = var.os_type

  ciuser     = var.ciuser
  cipassword = var.cipassword
  ciupgrade  = var.ciupgrade
  ipconfig0  = var.ipconfig0
  skip_ipv6  = var.skip_ipv6

  cpu {
    cores   = var.cpu_cores
    sockets = var.cpu_sockets
    vcores  = var.cpu_vcores
    type    = var.cpu_type
  }

  memory = var.memory
  scsihw = var.scsihw

  serial {
    id = var.serial_id
  }

  # We have to specify the disk from our template, else Terraform will think it's not supposed to be there
  disk {
    slot       = "scsi0"
    type       = "disk"
    storage    = var.disk_storage
    # The size of the disk should be at least as big as the disk in the template. If it's smaller, the disk will be recreated
    size       = var.disk_size
    emulatessd = var.emulatessd
  }

  disk {
    slot    = "ide1"
    type    = "cloudinit"
    storage = var.cloudinit_storage
  }

  dynamic "disk" {
    for_each = local.extra_disks_by_slot

    content {
      slot       = disk.value.slot
      type       = "disk"
      storage    = disk.value.storage
      size       = disk.value.size
      cache      = var.extra_disk_cache
      iothread   = var.extra_disk_iothread
      discard    = var.extra_disk_discard
      emulatessd = var.extra_disk_emulatessd
    }
  }

  network {
    id     = var.network_id
    bridge = var.network_bridge
    model  = var.network_model
  }

  sshkeys = var.ssh_keys
}