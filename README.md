# Dotfiles

Minimalist Arch Linux dotfiles focused on Hyprland/Omarchy desktop with essential tools only.

## Overview

This repository provides a clean, reproducible Arch Linux setup with:

- **Configuration management** - Just 16 essential configs, nothing more
- **Package management** - Curated set of core tools only
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

### 2. Run the installer

A single script handles everything — packages, symlinks, services, and optional extras:

```bash
./install.sh
```

**What it does (in order):**
1. Installs all Arch Linux packages via `pacman` and `yay`
2. Symlinks dotfiles and configs into `$HOME`
3. Sets permissions on `.ssh` and `.gnupg`
4. Deploys `/etc/hosts` and udev rules
5. Configures AppArmor kernel parameters
6. Enables systemd user services

**Packages installed:**
- **Core:** git, curl, wget, base-devel, linux-headers
- **Security:** linux-hardened, linux-lts, apparmor, apparmor.d (2000+ profiles)
- **Shell:** fish, fzf, ripgrep, fd, bat, eza, dust, btop, fastfetch, jq, wl-clipboard
- **Dev:** neovim, docker, docker-compose, lazygit, lazydocker, act, github-cli, git-delta
- **Desktop:** librewolf-bin (via AUR)
- **System:** flatpak, power-profiles-daemon, fwupd, openssh, wireguard-tools, rsync

---

### 3. Flags

```bash
./install.sh [options]
```

| Flag | Description |
|------|-------------|
| `--dry-run, -n` | Preview all actions without executing |
| `--skip-packages` | Skip package installation (symlinks/services only) |
| `--backup, -b` | Backup conflicting files with `.bak` suffix (recommended) |
| `--force, -f` | Remove conflicting files/symlinks (destructive) |
| `--merge, -m` | Open nvim diff to merge conflicts into dotfiles source |
| `--with-vpn` | Install WireGuard config to `/etc/wireguard/` |
| `--with-nas-sync` | Enable NAS sync timers |
| `--help, -h` | Show help message |

**Common invocations:**

```bash
# Preview everything without making changes
./install.sh --dry-run

# Fresh install (backup any conflicts)
./install.sh --backup

# Skip packages, just re-symlink dotfiles
./install.sh --skip-packages --backup

# Full install with VPN and NAS sync
./install.sh --backup --with-vpn --with-nas-sync
```

---

### 4. Configure NAS sync (optional)

Run with the `--with-nas-sync` flag to enable automatic NAS synchronization:

```bash
./install.sh --skip-packages --with-nas-sync
```

The script will prompt for your NAS rsync password. You can also set it manually:

```bash
echo 'your_nas_password' > ~/.config/nas-sync/rsync-password
chmod 600 ~/.config/nas-sync/rsync-password
```

NAS sync timers run hourly and sync:
- `~/Documents` ↔ NAS `documents` module
- `~/Music` ↔ NAS `music` module
- `~/Photos` ↔ NAS `photos` module
- `~/Audiobooks` ↔ NAS `audiobooks` module
- `~/Books` ↔ NAS `books` module

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

After adding new configs or scripts under `root/home/`, re-run:

```bash
./install.sh --skip-packages --backup
```

---

## Repository Structure

```
dotfiles/
├── omarchy/                    # Omarchy fork (git submodule → ~/.local/share/omarchy)
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
└── install.sh                  # Single installer: packages + dotfiles + services
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
└── install.sh                  # Single installer: packages + dotfiles + services

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
- `dust` - Better du
- `btop` - System monitor

**Git Tools:**
- `git` - Version control
- `gh` - GitHub CLI
- `lazygit` - Git TUI
- `git-delta` - Better diffs

**Development:**
- `neovim` - Text editor
- `docker` - Containers
- `lazydocker` - Docker TUI
- `act` - GitHub Actions locally

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

---

## Security

This setup includes comprehensive security hardening:

### Hardened Kernels

- **linux-hardened** - Security-focused kernel with additional hardening patches
- **linux-lts** - Long-term support kernel for stability

Both kernels are installed and available in your bootloader.

### AppArmor Mandatory Access Control

AppArmor is configured and enabled with:
- **2000+ security profiles** covering system applications and popular software
- **LSM (Linux Security Modules)** properly configured in kernel parameters
- **Complain mode by default** - Logs violations without blocking (safe for testing)

Key applications protected by AppArmor:
- Firefox, Brave, Chromium (browsers)
- Docker and containerization
- VS Code and development tools
- Flatpak sandboxed applications
- System services and daemons

**Check AppArmor status:**
```bash
sudo aa-status                    # View loaded profiles and active processes
sudo journalctl -xe | grep apparmor  # View AppArmor logs
```

**Switch to enforce mode** (after testing):
```bash
yay -S apparmor.d.enforced       # Replace complain mode with enforce mode
sudo reboot
```

In enforce mode, AppArmor will actively block policy violations for maximum security.

---

## Omarchy Submodule

Omarchy is tracked as a git submodule pointing at the personal fork:
[`github.com/funkybooboo/omarchy`](https://github.com/funkybooboo/omarchy)

`install.sh` symlinks `dotfiles/omarchy/` → `~/.local/share/omarchy`, which is where
Omarchy expects to live. The `omarchy-*` commands all work normally against the fork.

### Fresh clone

When cloning dotfiles on a new machine, the submodule is initialised automatically by `install.sh`:

```bash
git clone git@github.com:funkybooboo/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --backup
```

Or manually:

```bash
git clone --recurse-submodules git@github.com:funkybooboo/dotfiles.git ~/dotfiles
```

### Editing omarchy

Make changes directly inside `dotfiles/omarchy/` (or the separate clone at `~/projects/omarchy/`
— they share the same remote). Commit and push from within that directory:

```bash
cd ~/dotfiles/omarchy
# ... make changes ...
git add .
git commit -m "my change"
git push
```

Then record the new commit in dotfiles:

```bash
cd ~/dotfiles
git add omarchy
git commit -m "chore: advance omarchy submodule pin"
git push
```

### Pulling your latest fork changes

```bash
cd ~/dotfiles
git submodule update --remote omarchy
git add omarchy
git commit -m "chore: advance omarchy submodule pin"
```

The `update` script does this automatically after running `omarchy-update`.

### Syncing upstream changes from basecamp/omarchy

```bash
cd ~/dotfiles/omarchy
git fetch https://github.com/basecamp/omarchy.git master
git merge FETCH_HEAD          # or: git rebase FETCH_HEAD
git push                      # push merged result to your fork
```

Then advance the pin in dotfiles as above.

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
