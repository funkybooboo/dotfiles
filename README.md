# Dotfiles

Minimalist Arch Linux dotfiles focused on Hyprland/Omarchy desktop with essential tools only.

## Overview

This repository provides a clean, reproducible Arch Linux setup with:

- **Configuration management** - Just 16 essential configs, nothing more
- **Package management** - 48 curated installers for core tools only
- **Hyprland/Omarchy** - Wayland compositor with custom configurations
- **Developer tools** - Neovim, Git, Docker, and essential CLI utilities
- **Minimalist philosophy** - No bloat, only what you actually use

### Key Features

- **Arch Linux only** - Simplified, focused on one distro
- **Idempotent setup** - Safe to run multiple times without breaking existing configs
- **Optional NAS sync** - Automatic hourly rsync backups to NAS (opt-in with `--with-nas-sync`)
- **Smart power management** - Automatic profile switching on AC/battery
- **Ghostty terminal** - Modern GPU-accelerated terminal emulator
- **LibreWolf browser** - Privacy-focused Firefox fork

---

## Quick Start (Fresh Arch System)

### 1. Clone your dotfiles

```bash
git clone git@github.com:funkybooboo/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

---

### 2. Install packages (optional)

Install all packages:
```bash
./install.sh
```

Or combine with setup:
```bash
./setup.sh --install --backup
```

**What gets installed:**
- **Core:** git, curl, wget, base-devel, linux-headers
- **Shell:** fish, starship, zoxide, fzf, ripgrep, fd, bat, eza, dust, btop, fastfetch, jq, wl-clipboard
- **Dev:** neovim, docker, rust, go, python, lazygit, lazydocker, act, github-cli
- **Desktop:** librewolf-bin (via AUR)
- **System:** flatpak, power-profiles-daemon, fwupd

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

### 5. When you add new files or scripts

After adding new configs or scripts under `home/`, re-run:

```bash
./setup.sh --backup  # Re-symlink new files
```

---

## Repository Structure

```
dotfiles/
├── root/                       # Files to be symlinked
│   ├── home/                   # User home directory files
│   │   ├── .config/           # Configuration files
│   │   │   ├── fish/          # Fish shell
│   │   │   ├── nvim/          # Neovim
│   │   │   ├── opencode/      # OpenCode AI
│   │   │   └── systemd/       # User systemd services
│   │   ├── .local/
│   │   │   ├── bin/           # Custom scripts and commands
│   │   │   └── lib/           # Shared library scripts
│   │   ├── .gitconfig         # Git configuration
│   │   ├── .vimrc             # Vim configuration
│   │   └── .ssh/config        # SSH configuration
│   └── etc/                    # System-wide configs
│       ├── hosts              # Custom /etc/hosts
│       └── udev/rules.d/      # Udev rules
├── install.sh                  # Simple package installer
└── setup.sh                    # Main setup script

Custom Scripts in .local/bin:
  • btrfs-snapshot      - Create BTRFS snapshots
  • clean-disk          - System cleanup script
  • clean-memory        - Free up system memory
  • gg                  - AI-powered git commit helper
  • update              - System update script
  • update-firmware     - Firmware update script
  • vpn                 - VPN management (home/proton/usu)
  • sync-*              - NAS sync scripts (documents/music/photos/audiobooks)
```

---

## Core Installed Tools

**CLI Essentials:**
- `bat` - Better cat with syntax highlighting
- `eza` - Better ls with colors and icons
- `fd` - Better find
- `ripgrep` - Better grep
- `fzf` - Fuzzy finder
- `zoxide` - Smart cd
- `dust` - Better du
- `starship` - Shell prompt
- `btop` - System monitor

**Git Tools:**
- `git` - Version control
- `gh` - GitHub CLI
- `lazygit` - Git TUI

**Development:**
- `neovim` - Text editor
- `mise` - Runtime version manager
- `docker` - Containers
- `lazydocker` - Docker TUI
- `act` - GitHub Actions locally
- `rust` - Rust toolchain
- `python-pip` - Python package manager

**Desktop:**
- `hyprland` - Wayland compositor
- `waybar` - Status bar
- `ghostty` - Terminal
- `librewolf` - Browser
- `flatpak` - App sandboxing

---

## Philosophy

This dotfiles repository follows these principles:

1. **Minimalism** - Only install what you actually use
2. **Arch-only** - One distro, one way, no complexity
3. **Idempotency** - Safe to run setup repeatedly
4. **Transparency** - Every file is visible and editable
5. **Version control** - Everything tracked in git
6. **Modularity** - Each installer is independent

---

## Maintenance

### Updating all packages

```bash
update                # Uses custom script (yay + flatpak + omarchy + firmware)
```

Or manually:
```bash
yay -Syu              # Update system
flatpak update        # Update flatpaks
```

### Clean up old packages

```bash
clean-disk            # Comprehensive cleanup script
```

Or manually:
```bash
yay -Yc               # Clean unneeded dependencies
flatpak uninstall --unused
```

---

## License

MIT License - See [LICENSE](LICENSE) for details
