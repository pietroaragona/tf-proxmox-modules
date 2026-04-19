# tf-proxmox-modules

Terraform modules for provisioning Proxmox resources with the `Telmate/proxmox` provider.

## Modules

This repository currently contains:

| Module | Purpose |
| --- | --- |
| `lxc-container` | Create and configure a Proxmox LXC container |
| `virtual-machine` | Create and configure a Proxmox QEMU virtual machine cloned from a template |

## Requirements

- Terraform/OpenTofu compatible with the module syntax in this repository
- Proxmox VE
- Provider: `Telmate/proxmox` `3.0.2-rc07`

## Virtual machine module

Path: `./virtual-machine`

### Features

- clone-based VM creation from an existing Proxmox template
- cloud-init support
- configurable CPU, memory, network and disk settings
- static management of:
	- `scsi0` for the main VM disk
	- `ide1` for the cloud-init disk
- optional additional SCSI disks via `extra_disks`

### Basic example

```hcl
module "vm" {
	source = "./virtual-machine"

	vmid         = 101
	vm_name      = "vm-example"
	proxmox_host = "pve"
	template_name = "ubuntu-2404-cloudinit-template"

	ciuser     = "ubuntu"
	cipassword = "change-me"
	ssh_keys   = file("~/.ssh/id_ed25519.pub")
	ipconfig0  = "ip=192.168.1.50/24,gw=192.168.1.1"
}
```

### Additional disk example

```hcl
module "vm" {
	source = "./virtual-machine"

	vmid          = 101
	vm_name       = "vm-storage"
	proxmox_host  = "pve"
	template_name = "ubuntu-2404-cloudinit-template"

	ciuser     = "ubuntu"
	cipassword = "change-me"
	ssh_keys   = file("~/.ssh/id_ed25519.pub")
	ipconfig0  = "ip=192.168.1.60/24,gw=192.168.1.1"

	extra_disks = [
		{
			slot    = "scsi1"
			storage = "local-lvm"
			size    = "100G"
		},
		{
			slot    = "scsi2"
			storage = "fast-ssd"
			size    = "200G"
		}
	]

	extra_disk_cache      = "none"
	extra_disk_iothread   = true
	extra_disk_discard    = false
	extra_disk_emulatessd = false
}
```

### Additional disk notes


- If `extra_disks = []`, the module behaves exactly like before and only manages the main disk and cloud-init disk.
- Each additional disk requires:
	- `slot`
	- `storage`
	- `size`
- Slots must be unique.
- Reserved slots are intentionally excluded:
	- `scsi0` is used by the main VM disk
	- `ide1` is used by cloud-init

### Recommended settings for extra disks

If the guest OS aggregates the additional disks with `LVM`, the current defaults are a sensible starting point:

- `extra_disk_cache = "none"`
- `extra_disk_iothread = true`
- `extra_disk_discard = false`
- `extra_disk_emulatessd = false`

If the underlying physical disks are SSDs and TRIM is supported end-to-end, you may want to set:

```hcl
extra_disk_discard    = true
extra_disk_emulatessd = true
```

### Main inputs

| Name | Type | Default | Notes |
| --- | --- | --- | --- |
| `vmid` | `number` | n/a | Proxmox VM ID |
| `vm_name` | `string` | n/a | VM name |
| `proxmox_host` | `string` | n/a | Proxmox target node |
| `template_name` | `string` | n/a | Source template name for clone |
| `ciuser` | `string` | n/a | Cloud-init user |
| `cipassword` | `string` | n/a | Cloud-init password |
| `ssh_keys` | `string` | n/a | SSH public keys for cloud-init |
| `ipconfig0` | `string` | n/a | Cloud-init network configuration |
| `tags` | `string` | `"tf-managed"` | VM tags |
| `vm_state` | `string` | `"started"` | Desired VM state |
| `agent` | `number` | `1` | Enable QEMU guest agent |
| `os_type` | `string` | `"cloud-init"` | Guest provisioning mode |
| `cpu_cores` | `number` | `2` | CPU cores |
| `cpu_sockets` | `number` | `1` | CPU sockets |
| `cpu_vcores` | `number` | `0` | Exposed vcores |
| `cpu_type` | `string` | `"host"` | CPU type |
| `memory` | `number` | `2048` | Memory in MB |
| `scsihw` | `string` | `"virtio-scsi-single"` | SCSI controller type |
| `disk_storage` | `string` | `"local-lvm"` | Storage for `scsi0` |
| `disk_size` | `string` | `"5G"` | Size for `scsi0` |
| `emulatessd` | `bool` | `true` | Expose `scsi0` as SSD |
| `cloudinit_storage` | `string` | `"local-lvm"` | Storage for `ide1` cloud-init disk |
| `network_id` | `number` | `0` | Network device ID |
| `network_bridge` | `string` | `"vmbr0"` | Network bridge |
| `network_model` | `string` | `"virtio"` | Network model |

### Extra disk inputs

| Name | Type | Default | Notes |
| --- | --- | --- | --- |
| `extra_disks` | `list(object({ slot = string, storage = string, size = string }))` | `[]` | Extra SCSI disks to attach to the VM |
| `extra_disk_cache` | `string` | `"none"` | Cache mode for extra disks |
| `extra_disk_iothread` | `bool` | `true` | Enable `iothread` on extra disks |
| `extra_disk_discard` | `bool` | `false` | Enable discard/TRIM on extra disks |
| `extra_disk_emulatessd` | `bool` | `false` | Expose extra disks as SSD |

### Outputs

| Name | Description |
| --- | --- |
| `ipv4` | Default IPv4 address reported by Proxmox |
| `username` | Cloud-init username |
| `name` | VM name |

## LXC container module

Path: `./lxc-container`

### Features

- create an LXC container on a target node
- root filesystem configuration
- bridge networking with DHCP or static IP
- optional nesting support

### Example

```hcl
module "lxc" {
	source = "./lxc-container"

	vmid        = 201
	target_node = "pve"
	hostname    = "container-example"
	ostemplate  = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
	password    = "change-me"

	network_ip = "192.168.1.70"
	network_gw = "192.168.1.1"

	ssh_public_keys = file("~/.ssh/id_ed25519.pub")
}
```

### Main inputs

| Name | Type | Default | Notes |
| --- | --- | --- | --- |
| `vmid` | `number` | n/a | Container ID |
| `target_node` | `string` | n/a | Proxmox node |
| `hostname` | `string` | n/a | Container hostname |
| `ostemplate` | `string` | n/a | Template path |
| `password` | `string` | n/a | Root password |
| `unprivileged` | `bool` | `true` | Use unprivileged container |
| `memory` | `number` | `768` | Memory in MB |
| `start` | `bool` | `true` | Start after creation |
| `rootfs_storage` | `string` | `"local-lvm"` | Root filesystem storage |
| `rootfs_size` | `string` | `"4G"` | Root filesystem size |
| `network_name` | `string` | `"eth0"` | Network device name |
| `network_bridge` | `string` | `"vmbr0"` | Network bridge |
| `network_ip` | `string` | `"dhcp"` | DHCP or static IP without CIDR suffix |
| `network_gw` | `string` | `"192.168.1.1"` | Gateway |
| `tags` | `string` | `"tf-managed"` | Container tags |
| `ssh_public_keys` | `string` | `""` | SSH public keys |
| `nesting` | `bool` | `true` | Enable nesting |

### Outputs

| Name | Description |
| --- | --- |
| `ipv4` | Container IPv4 address or `-` when using DHCP |
| `username` | Default username, always `root` |
| `vmid` | Container ID |
