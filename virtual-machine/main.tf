resource "proxmox_vm_qemu" "vm" {
  vmid        = var.vmid
  name        = var.vm_name
  target_node = var.proxmox_host
  tags        = var.tags

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

  disks {
    scsi {
      scsi0 {
        # We have to specify the disk from our template, else Terraform will think it's not supposed to be there
        disk {
          storage = var.disk_storage
          # The size of the disk should be at least as big as the disk in the template. If it's smaller, the disk will be recreated
          size       = var.disk_size
          emulatessd = var.emulatessd
        }
      }
    }
    ide {
      ide1 {
        cloudinit {
          storage = var.cloudinit_storage
        }
      }
    }
  }

  network {
    id     = var.network_id
    bridge = var.network_bridge
    model  = var.network_model
  }

  sshkeys = var.ssh_keys
}