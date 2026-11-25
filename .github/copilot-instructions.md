# Copilot instructions: tf-proxmox-modules

Reusable Terraform/OpenTofu modules for Proxmox VE (homelab), using the `Telmate/proxmox` provider pinned to `3.0.2-rc07`. There is no application code, CI or test suite: the modules are consumed by other repos (e.g. `home-lab-iac/deploy-repo`) via `source`.

## Commands

```shell
terraform fmt -recursive                          # formatting (only lint step)
terraform validate                                # inside a module dir, after terraform init
cd virtual-machine/test && terraform init && terraform plan   # local smoke test
```

`virtual-machine/test/` is a local root module (state, tfvars, real credentials/SSH keys); it is git-ignored. Never commit it or echo its contents. The devcontainer provides terraform, tflint and terraform-docs.

## Architecture

- `virtual-machine/`: QEMU VM cloned from a cloud-init template. `scsi0` (main disk) and `ide1` (cloud-init disk) are managed statically, so their slots are reserved; extra disks go through `extra_disks` (list of `slot`/`storage`/`size`, unique slots). Outputs: `ipv4`, `username`, `name`.
- `lxc-container/`: LXC container (rootfs, bridge network DHCP/static, nesting, mount/fuse features). `terraform.tfvars.example` documents the inputs.
- Each module is standalone: `main.tf`, `variables.tf`, `providers.tf` (+ `output.tf`).

## Conventions

- Keep the provider version identical in every module's `providers.tf`.
- Secrets (cloud-init/container passwords) are `sensitive = true`. Proxmox credentials are never in the repo: pass `PM_API_TOKEN_ID`, `PM_API_TOKEN_SECRET`, `TF_VAR_pm_api_url` via environment (devcontainer forwards them from the host).
- Resources get the default tag `tf-managed`.
- Changes must stay backward compatible (e.g. `extra_disks = []` leaves behavior unchanged).
- Update the `README.md` input/output tables whenever variables or outputs change.
- `ipconfig0` with `ip=dhcp` cannot be combined with a gateway.
- Never commit `*.tfstate*`, `*.tfvars` (the `.example` is fine) or `.terraform/`.
- Homelab VM id convention (when proposing examples): 4-digit vmid whose last 3 digits are the IP's last octet in `192.168.1.0/24` (7=test VM, 8=prod VM, 6=test k8s, 9=prod k8s); static IPs in `.200–.253`.
