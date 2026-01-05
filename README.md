# 🗂️ Dotfiles

---

## 🚀 Quick Start (Fresh System)

### 1. Clone your dotfiles

```bash
git clone git@github.com:funkybooboo/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

---

### 2. Install packages (optional)

Install ClamAV antivirus:
```bash
./install/packages/special/clamav.sh
```

Or run the full installation orchestration:
```bash
./install/orchestration/install-all.sh
```

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
* Sets up NAS sync timers for Documents, Music, Photos, and Audiobooks
* Enables battery notification timer
* Installs power profile auto-switching udev rule
* Prompts for NAS rsync password (stored securely in `~/.config/nas-sync/rsync-password`)

**Flags:**
- `--dry-run, -n`: Preview actions without executing
- `--backup, -b`: Backup existing files with `.bak` suffix (safe, recommended)
- `--force, -f`: Remove existing files (destructive)
- `--help, -h`: Show help message

---

### 4. Configure NAS sync

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

#### 🧊 NixOS

```bash
sudo mkdir -p /etc/nixos
sudo cp root/etc/nixos/configuration.nix /etc/nixos/configuration.nix
sudo nixos-rebuild switch
```

#### 🐧 Arch Linux

```bash
./install/orchestration/pre-reboot.sh
# The scripts will prompt you to reboot
./install/orchestration/post-reboot.sh
```

---

### 6. Proton Drive sync (optional)

If you also want to sync with Proton Drive:

```bash
rclone config
sync-docs        # ~/Documents ↔ Proton Drive
sync-music       # ~/Music ↔ Proton Drive
sync-audiobooks  # ~/Audiobooks ↔ Proton Drive
```

---

### 7. When you add new files or scripts

After adding new configs or scripts under `home/`, re-run:

```bash
./setup.sh --backup
```

to link them into place.

---

## 📂 Repository Structure

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
│   ├── packages/                  # Package installers (210 scripts)
│   │   ├── core/                  # Core system packages
│   │   ├── desktop/               # Desktop environment
│   │   ├── dev/                   # Development tools
│   │   ├── fonts/                 # Font packages
│   │   └── special/               # Special installs (libvirt, plymouth, etc)
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

## 🧹 Notes

* **Safe by default**: The setup script aborts on conflicts (use `--backup` for safety)
* **Use `--dry-run`** to preview actions before applying
* **NAS sync**: Automatic hourly syncing when connected to home network/VPN
* **Proton Drive sync**: Manual sync scripts in `.local/bin/proton/`
* Designed to work on Arch Linux, NixOS, Ubuntu, and other Linux distros

---

## 🔐 Security

- NAS rsync password stored in `~/.config/nas-sync/rsync-password` with 600 permissions
- ClamAV configured to scan user directories with proper ACLs
- GPG and SSH keys managed separately (see `install/packages/special/`)
