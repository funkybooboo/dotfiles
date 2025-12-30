# System Documentation

**Last Updated:** 2025-12-30

## Quick Links

- [System Overview](overview.md) - OS info, specs, and system summary
- [Installed Software](packages.md) - All installed packages and applications
- [System Services](services.md) - Running and enabled services
- [Brightness Control](brightness-control.md) - Custom brightness control system
- [Backup & Snapshots](backup-snapshots.md) - Btrfs snapshot and recovery system
- [NAS Sync](nas-sync.md) - Automated NAS synchronization setup
- [VPN Management](vpn.md) - VPN setup and usage guide

## Omarchy Configuration

All Omarchy customizations are maintained in `~/dotfiles/omarchy/`:
- 141 utility scripts
- 27 Hyprland configuration files
- See [Omarchy README](../omarchy/README.md) for details

## Reference Files

Package lists in `~/dotfiles/system-docs/`:
- `installed_packages.txt` - All 1,156 packages
- `explicitly_installed_packages.txt` - 188 manually installed packages
- `pip_packages.txt` - 86 pip packages
- `running_processes.txt` - Top 50 processes by memory
- `services_running.txt` - 25 running services
- `services_enabled.txt` - 21 enabled services

## System Specs

- **OS:** Arch Linux
- **Kernel:** 6.17.9-arch1-1
- **Desktop:** Hyprland (Wayland compositor)
- **Filesystem:** Btrfs
- **Bootloader:** Limine
