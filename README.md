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

`root/` is a **mirror of the filesystem** — its layout maps exactly to where files land on disk.
Individual files are symlinked by `link_tree`; whole directories (submodules) are symlinked by
`link_dir`.

```
dotfiles/
├── root/                           # Mirrors the filesystem
│   ├── home/                       # → $HOME
│   │   ├── .config/
│   │   │   ├── fish/               # Fish shell config
│   │   │   ├── hypr/               # Hyprland config
│   │   │   ├── nvim/               # Neovim config
│   │   │   ├── omarchy/            # Omarchy user overrides (hooks, branding, themes)
│   │   │   ├── opencode/           # OpenCode AI config
│   │   │   └── systemd/            # User systemd services
│   │   ├── .local/
│   │   │   ├── bin/                # Custom scripts (update, gg, vpn, …)
│   │   │   ├── lib/                # Shared library scripts
│   │   │   └── share/
│   │   │       └── omarchy/        # [submodule] funkybooboo/omarchy fork
│   │   ├── .gitconfig
│   │   ├── .vimrc
│   │   └── .ssh/config
│   └── etc/                        # → /etc
│       ├── hosts
│       └── udev/rules.d/
└── install.sh                      # Packages + symlinks + services
```

**Custom scripts in `.local/bin`:**

| Script | Purpose |
|--------|---------|
| `update` | Full system update (yay + flatpak + omarchy + firmware) |
| `gg` | AI-powered git commit helper |
| `vpn` | VPN management (home / proton / usu) |
| `clean-disk` | System cleanup |
| `clean-memory` | Free up memory |
| `btrfs-snapshot` | Create BTRFS snapshots |
| `sync-*` | NAS sync scripts (documents / music / photos / audiobooks) |

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

## Submodules

Submodules are full git repositories nested inside this repo. They live under `root/` so their
path mirrors where they land on disk. `install.sh` symlinks each submodule directory as a whole
unit (via `link_dir`) so the internal `.git` reference stays intact and all git operations work
normally inside them.

### How it works

| Location in repo | Symlinked to | Purpose |
|---|---|---|
| `root/home/.local/share/omarchy/` | `~/.local/share/omarchy` | Omarchy fork — all `omarchy-*` commands run from here |

`install.sh` reads `.gitmodules` automatically — any submodule placed under
`root/home/.local/share/` is picked up and linked without any code changes.

---

### Installing on a fresh machine

`install.sh` initialises and clones all submodules before symlinking:

```bash
git clone git@github.com:funkybooboo/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --backup        # backs up any existing ~/.local/share/omarchy
```

Or clone with submodules already populated:

```bash
git clone --recurse-submodules git@github.com:funkybooboo/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --skip-packages --backup
```

---

### Editing a submodule

The submodule is a normal git repo. Make changes, commit, and push from inside it:

```bash
cd ~/dotfiles/root/home/.local/share/omarchy
# ... make changes ...
git add .
git commit -m "my change"
git push
```

Then record the new commit pin in dotfiles so others (and future installs) get the same version:

```bash
cd ~/dotfiles
git add root/home/.local/share/omarchy
git commit -m "chore: advance omarchy submodule pin"
git push
```

> The `update` script does the pin advance automatically after `omarchy-update` runs.

---

### Updating a submodule to its latest fork commit

Pull the latest from the fork remote and advance the pin:

```bash
cd ~/dotfiles
git submodule update --remote root/home/.local/share/omarchy
git add root/home/.local/share/omarchy
git commit -m "chore: advance omarchy submodule pin"
git push
```

Or just run `update` — it does this automatically.

---

### Syncing upstream changes from basecamp/omarchy into your fork

```bash
cd ~/dotfiles/root/home/.local/share/omarchy
git fetch https://github.com/basecamp/omarchy.git master
git merge FETCH_HEAD          # or: git rebase FETCH_HEAD
git push                      # push merged result to your fork
```

Then advance the pin in dotfiles as above.

---

### Adding a new submodule

Place it under `root/home/` at the path that mirrors its destination on disk:

```bash
# Example: adding a new tool that lives at ~/.local/share/mytool
git submodule add git@github.com:you/mytool.git root/home/.local/share/mytool
git add .gitmodules root/home/.local/share/mytool
git commit -m "add mytool as submodule"
```

`install.sh` will automatically detect it (via `.gitmodules`) and symlink it on the next run.

---

### Removing a submodule

```bash
git submodule deinit root/home/.local/share/omarchy
git rm root/home/.local/share/omarchy
git add .gitmodules
git commit -m "remove omarchy submodule"
```

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
