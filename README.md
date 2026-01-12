# Dotfiles

A comprehensive Linux dotfiles and system configuration management solution with multi-distribution support, extensive automation, and 500+ tracked configuration files.

## Overview

This repository provides a complete, reproducible system setup for Linux environments, combining:

- **Configuration management** - Symlink-based deployment of all personal dotfiles
- **Package management** - Unified installer system with 219 packages across Arch, Ubuntu, and NixOS
- **Automation** - Systemd timers for battery notifications, power profile switching, and optional NAS sync
- **Deep customization** - Full Hyprland/Omarchy integration with 169 customized files
- **Developer tools** - 24 custom commands and 10 library scripts for system management

### Key Features

- **Multi-distribution support** - Works on Arch Linux, Ubuntu/Debian, and NixOS
- **Idempotent setup** - Safe to run multiple times without breaking existing configs
- **Optional NAS sync** - Automatic hourly rsync backups to NAS (opt-in with `--with-nas-sync`)
- **Smart power management** - Automatic profile switching on AC/battery
- **VPN integration** - Unified VPN manager supporting multiple providers
- **Custom commands** - System updater, disk cleanup, 2FA manager, GitHub backups
- **Cloud sync** - Proton Drive integration for documents and media
- **Security focused** - ClamAV scanning, secure credential storage, proper permissions

See [docs/](docs/) for detailed feature documentation.

---

## Quick Start (Fresh System)

### 1. Clone your dotfiles

```bash
git clone git@github.com:funkybooboo/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

---

### 2. Install packages (optional)

Install all 219 packages:
```bash
./install/orchestration/install-all.sh
```

Or use phased installation (recommended for fresh systems):
```bash
./install/orchestration/pre-reboot.sh    # System packages
# Reboot here
./install/orchestration/post-reboot.sh   # User packages
```

Individual package installation:
```bash
./install/packages/core/neovim.sh        # Install Neovim
./install/packages/special/clamav.sh     # Install ClamAV antivirus
./install/packages/desktop/brave.sh      # Install Brave browser
```

**Package categories:**
- **core/** (60 packages) - Essential utilities: git, neovim, bat, fd, ripgrep, fzf, jq, eza, etc.
- **dev/** (35 packages) - Development tools: languages, build tools, version managers
- **desktop/** (18 packages) - GUI applications: Brave, Discord, Obsidian, VLC, OBS
- **special/** (18 packages) - Complex installs: Docker, CUDA, libvirt, JetBrains Toolbox
- **fonts/** - Font packages for desktop use

---

### 3. Bootstrap your dotfiles

Preview what will be linked:

```bash
./setup.sh --dry-run
```

Then apply (choose one):

```bash
# Safe mode: Abort if conflicts exist
./setup.sh

# Backup mode: Backup existing files with .bak suffix (recommended)
./setup.sh --backup

# Force mode: Remove existing files/symlinks (destructive)
./setup.sh --force
```

What this does:

* Symlinks commands from `home/.local/bin/*` → `~/.local/bin/*`
* Symlinks library scripts from `home/.local/lib/*` → `~/.local/lib/*`
* Symlinks omarchy customizations from `home/.local/share/omarchy/*` → `~/.local/share/omarchy/*`
* Symlinks each folder under `home/.config/*` → `~/.config/*`
* Symlinks all remaining dotfiles in `home/` → `$HOME`
* Enables battery notification timer
* Installs power profile auto-switching udev rule

**Flags:**
- `--dry-run, -n`: Preview actions without executing
- `--backup, -b`: Backup existing files with `.bak` suffix (safe, recommended)
- `--force, -f`: Remove existing files (destructive)
- `--with-nas-sync`: Enable NAS sync timers setup (optional)
- `--help, -h`: Show help message

---

### 4. Configure NAS sync (optional)

If you want to enable automatic NAS synchronization, run setup with the `--with-nas-sync` flag:

```bash
./setup.sh --backup --with-nas-sync
```

The setup script will prompt for your NAS rsync password. You can also set it manually:

```bash
echo 'your_nas_password' > ~/.config/nas-sync/rsync-password
chmod 600 ~/.config/nas-sync/rsync-password
```

NAS sync timers will run hourly and sync:
- `~/Documents` ↔ NAS `documents` module
- `~/Music` ↔ NAS `music` module
- `~/Photos` ↔ NAS `photos` module
- `~/Audiobooks` ↔ NAS `audiobooks` module

Check sync status:
```bash
systemctl --user list-timers              # List all timers
systemctl --user status nas-sync-documents.timer
journalctl --user -u nas-sync-documents.service -f  # Watch logs
```

Manual sync:
```bash
systemctl --user start nas-sync-documents.service
```

---

### 5. System configuration (optional)

#### NixOS

```bash
sudo mkdir -p /etc/nixos
sudo cp root/etc/nixos/configuration.nix /etc/nixos/configuration.nix
sudo nixos-rebuild switch
```

#### Arch Linux

```bash
./install/orchestration/pre-reboot.sh
# The scripts will prompt you to reboot
./install/orchestration/post-reboot.sh
```

---

### 6. Custom commands

After setup, you'll have access to 24 custom commands in `~/.local/bin/`:

**System Management:**
- `update` - Multi-distro system updater (NixOS/Ubuntu aware)
- `update-firmware` - Firmware update management
- `auto-update` - Scheduled system updates
- `rebuild` - System rebuild/reconfiguration
- `clean-disk` - Disk space cleanup utility
- `clean-memory` - Memory optimization

**VPN & Networking:**
- `vpn` - Unified VPN manager (home/debbie-local, Proton VPN, GlobalProtect)
- `sync-documents`, `sync-music`, `sync-photos`, `sync-audiobooks` - Manual NAS sync

**Cloud Sync:**
- `proton-sync` - Proton Drive synchronization
- `proton-sync-docs`, `proton-sync-music`, `proton-sync-audiobooks` - Specific syncs
- `update-rclone-2fa` - 2FA token management for Proton

**Development & Utilities:**
- `gg` - Git shortcut tool
- `audit` - System security audit
- `backup-github` - GitHub repository backup
- `2fa` - Two-factor authentication manager
- `btrfs-snapshot` - Btrfs snapshot management

---

### 7. Proton Drive sync (optional)

If you also want to sync with Proton Drive:

```bash
rclone config
sync-docs        # ~/Documents ↔ Proton Drive
sync-music       # ~/Music ↔ Proton Drive
sync-audiobooks  # ~/Audiobooks ↔ Proton Drive
```

---

### 8. When you add new files or scripts

After adding new configs or scripts under `home/`, re-run:

```bash
./setup.sh --backup
```

to link them into place.

---

## Repository Structure

```
dotfiles/
├── home/                          # Dotfiles & user configs (maps to ~/)
│   ├── .config/                   # XDG config directories (41 apps)
│   │   ├── nvim/                  # Neovim (LazyVim)
│   │   ├── hypr/                  # Hyprland WM (11 configs)
│   │   ├── waybar/                # Waybar status bar
│   │   ├── kitty/                 # Kitty terminal
│   │   ├── systemd/user/          # User systemd services & timers (11 units)
│   │   └── ...                    # 35+ more apps
│   ├── .local/
│   │   ├── bin/                   # User commands (24 scripts)
│   │   │   ├── vpn                # VPN manager
│   │   │   ├── update             # System updater
│   │   │   ├── sync-*             # NAS sync commands
│   │   │   ├── proton-sync*       # Proton Drive sync commands
│   │   │   ├── waybar/            # Waybar status scripts (6 scripts)
│   │   │   ├── hyprland/          # Hyprland helper (1 script)
│   │   │   └── break-reminder/    # Break reminder (1 script + config)
│   │   ├── lib/                   # Library scripts (10 scripts)
│   │   │   ├── sync-to-nas        # NAS sync backend
│   │   │   ├── good-time-to-run   # System readiness checker
│   │   │   ├── battery-notify     # Battery notification daemon
│   │   │   └── ...                # 7 more helpers
│   │   └── share/
│   │       └── omarchy/           # Omarchy customizations (169 files)
│   │           ├── bin/           # 141 customized scripts
│   │           ├── hypr/          # 27 customized Hyprland configs
│   │           └── README.md      # Omarchy customization docs
│   └── .{bashrc,gitconfig,...}    # Shell dotfiles (9 files)
├── install/                       # Installation scripts
│   ├── packages/                  # Package installers (219 scripts)
│   │   ├── core/                  # Core system packages (60)
│   │   ├── desktop/               # Desktop environment (18)
│   │   ├── dev/                   # Development tools (35)
│   │   ├── fonts/                 # Font packages
│   │   └── special/               # Special installs (18) - libvirt, plymouth, etc
│   └── orchestration/             # Install orchestration scripts
├── root/                          # System-level configs (maps to /)
│   └── etc/                       # System configuration files
│       ├── dnsmasq.conf           # DNS configuration
│       └── udev/                  # Power profile auto-switching
├── docs/                          # Documentation
│   ├── SOURCE_OF_TRUTH_COMPLETE.md    # Comprehensive documentation
│   ├── IDEMPOTENCY_AUDIT.md           # Idempotency verification
│   └── ...                            # Additional docs
├── system-docs/                   # System-specific documentation
├── setup.sh                       # Main dotfiles setup script
└── README.md                      # This file
```

**Total:** 500+ tracked files

---

## Notes

* **Safe by default**: The setup script aborts on conflicts (use `--backup` for safety)
* **Use `--dry-run`** to preview actions before applying
* **NAS sync**: Optional - use `--with-nas-sync` flag to enable automatic hourly syncing
* **Proton Drive sync**: Manual sync scripts available in `~/.local/bin/`
* Designed to work on Arch Linux, NixOS, Ubuntu, and other Linux distros

---

## Security

- NAS rsync password stored in `~/.config/nas-sync/rsync-password` with 600 permissions
- ClamAV configured to scan user directories with proper ACLs
- GPG and SSH keys managed separately (see `install/packages/special/`)
