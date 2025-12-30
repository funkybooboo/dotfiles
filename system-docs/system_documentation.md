# System Documentation
Generated: 2025-12-17

## System Overview
- **OS:** Arch Linux
- **Kernel:** 6.17.9-arch1-1
- **Total Packages:** 1,156
- **Explicitly Installed:** 188
- **Pip Packages:** 86

---

## Package Summary

### All Packages
- **File:** `~/installed_packages.txt` (1,156 packages)
- Lists all installed packages including dependencies

### Explicitly Installed Packages
- **File:** `~/explicitly_installed_packages.txt` (188 packages)
- These are packages you installed manually (not dependencies)

### Python Pip Packages
- **File:** `~/pip_packages.txt` (86 packages)
- Python packages installed via pip

---

## Key Installed Software

### Desktop Environment
- **Compositor:** Hyprland 0.52.2-2
- **Display Manager:** SDDM 0.21.0-6
- **Session Manager:** uwsm 0.25.2-1
- **Status Bar:** Waybar 0.14.0-5
- **Launcher:** Walker 2.12.2-2
- **Lock Screen:** Hyprlock 0.9.2-7
- **Idle Manager:** Hypridle 0.1.7-6
- **Notifications:** Mako 1.10.0-1
- **Screenshot:** Grim 1.5.0-2, Slurp 1.5.0-1, Satty 0.20.0-1
- **OSD:** SwayOSD 0.2.1-2

### Browsers
- Brave 1.85.116-1
- Firefox 146.0-1
- LibreWolf 146.0.0_2-1
- Omarchy Chromium 143.0.7499.109-15

### Development Tools
- **Editor:** Neovim 0.11.5-1 (omarchy-nvim)
- **IDE:** VSCodium 1.106.37943-1, JetBrains Toolbox 3.1.2.64642-1
- **Terminal:** Ghostty 1.2.3-2
- **Shell Tools:** Starship 1.24.1-1, Zoxide 0.9.8-2
- **Languages:** Python 3.13.11-1, Rust 1.92.0-1, Ruby 3.4.7-2, Clang 21.1.6-1, LLVM 21.1.6-1
- **Version Control:** Git 2.52.0-2, GitHub CLI 2.83.2-1, Lazygit 0.57.0-1
- **Containers:** Docker 29.1.3-1, Docker Buildx 0.30.1-1, Docker Compose 5.0.0-1, Lazydocker 0.24.2-1
- **Build Tools:** Base-devel 1-2
- **Environment Manager:** Mise 2025.11.3-1

### Productivity
- **Office:** LibreOffice Fresh 25.8.3-3
- **Note Taking:** Obsidian 1.10.6-1, Typora 1.12.4-1, Xournal++ 1.3.0-1
- **PDF Viewer:** Evince 48.1-1
- **Calculator:** GNOME Calculator 49.2-1
- **File Manager:** Nautilus 49.2-1

### Media
- **Video Player:** MPV 0.40.0-7
- **Video Editor:** Kdenlive 25.12.0-3
- **Screen Recorder:** OBS Studio 32.0.2-2, GPU Screen Recorder r1228.4363f8b-1
- **Image Viewer:** IMV 5.0.1-1
- **Image Editor:** Pinta 3.0.5-2, ImageMagick 7.1.2.11-1
- **Audio:** Pipewire 1.4.9-2 (full stack)

### Communication
- Signal Desktop 7.82.0-1
- Zoom 6.6.11-1
- LocalSend 1.17.0-2

### System Utilities
- **System Monitor:** Btop 1.4.5-1, Usage 2.6.0-1
- **Disk Usage:** Dust 1.2.3-1
- **File Search:** Plocate 1.1.23-1, Fd 10.3.0-1, Ripgrep 15.1.0-1
- **Fuzzy Finder:** Fzf 0.67.0-1
- **File Manager (CLI):** Yazi 25.5.31-2
- **Cat Alternative:** Bat 0.26.1-1
- **Ls Alternative:** Eza 0.23.4-1
- **AUR Helper:** Yay 12.5.7-1
- **Snapshots:** Snapper 0.13.0-2, Limine Snapper Sync 1.18.1-1
- **Brightness Control:** Brightnessctl 0.5.1-3 (custom wrapper)

### Network & VPN
- **VPN:** OpenVPN 2.6.17-1, Proton VPN CLI 0.1.2-1, WireGuard Tools 1.0.20250521-1
- **Firewall:** UFW 0.36.2-5, UFW-Docker 250710-1
- **Network Manager:** NetworkManager, IWD 3.10-1

### Virtualization
- Virt-Manager 5.1.0-1
- Docker (full stack)

### Gaming
- Steam 1.0.0.85-1

### Other Notable Tools
- **AI/LLM:** Ollama 0.13.3-1, Claude Code 2.0.69-1
- **Password Manager:** Proton Pass (GUI + CLI)
- **Printer:** CUPS 2.4.16-1, CUPS Browsed 2.1.1-1
- **Bluetooth:** Bluetui 0.8.0-1
- **Brightness:** Brightnessctl 0.5.1-3
- **Power Management:** Power Profiles Daemon 0.30-1
- **Boot Loader:** Limine 10.5.0-1
- **System Info:** Fastfetch 2.56.0-1, Inxi 3.3.40.1-1
- **Input Method:** Fcitx5 5.1.16-1

---

## Running Services (25 services)

### Core System Services
1. **systemd-journald** - Journal/logging service
2. **systemd-logind** - User login management
3. **systemd-udevd** - Device event management
4. **systemd-userdbd** - User database manager
5. **systemd-networkd** - Network configuration
6. **systemd-resolved** - DNS resolution
7. **systemd-timesyncd** - Time synchronization
8. **dbus-broker** - D-Bus message bus

### Display & Session
9. **sddm** - Simple Desktop Display Manager

### Network Services
10. **NetworkManager** - Network connection manager
11. **iwd** - Intel wireless daemon
12. **avahi-daemon** - mDNS/DNS-SD (network discovery)

### Security & Authentication
13. **polkit** - Authorization manager

### Power Management
14. **upower** - Power management daemon
15. **power-profiles-daemon** - Power profiles (performance/balanced/power-saver)
16. **rtkit-daemon** - Realtime scheduling for audio

### VPN
17. **proton.VPN** - Proton VPN daemon

### Bluetooth
18. **bluetooth** - Bluetooth service

### Printing
19. **cups** - CUPS print scheduler
20. **cups-browsed** - Remote CUPS printer discovery

### Containers
21. **docker** - Docker container engine
22. **containerd** - Container runtime

### Battery Monitoring
23. **batmond** - Battery level monitoring and logging

### Boot Management
24. **limine-snapper-sync** - Syncs boot entries with Snapper snapshots

### User Session
25. **user@1000** - User session for UID 1000

---

## Enabled Services (21 services)

Services set to start automatically on boot:

1. avahi-daemon
2. bluetooth
3. cups / cups-browsed
4. docker
5. getty@ (console login)
6. iwd
7. limine-snapper-sync
8. NetworkManager (+ dispatcher, wait-online)
9. nvidia-hibernate/resume/suspend (NVIDIA power management)
10. proton.VPN
11. sddm
12. systemd-network-generator
13. systemd-networkd
14. systemd-resolved
15. systemd-timesyncd
16. ufw (firewall)

---

## Brightness Control

### Overview
Custom brightness control system with intelligent step sizing and minimum brightness protection.

### Configuration
- **Control Tool:** Brightnessctl 0.5.1-3
- **OSD Display:** SwayOSD 0.2.1-2
- **Wrapper Script:** `~/.local/share/omarchy/bin/omarchy-cmd-brightness`
- **Key Bindings:** `~/.local/share/omarchy/default/hypr/bindings/media.conf`

### Behavior
- **Step Size:** 5% (jumps in increments of 5)
- **Minimum Brightness:** 1% (never goes to 0%)
- **Brightness Levels:** 1%, 5%, 10%, 15%, 20%, ..., 95%, 100%

### Smart Stepping Logic
- **From 1% → Up:** Jumps directly to 5% (not 6%)
- **From 5% → Down:** Drops to 1% (not 0%)
- **All Other Levels:** Normal 5% increments maintained
- **Result:** Brightness always aligns to multiples of 5, except for 1% minimum

### Key Bindings

**Normal brightness adjustment (5% steps):**
- `XF86MonBrightnessUp` - Increase brightness by 5%
- `XF86MonBrightnessDown` - Decrease brightness by 5%

**Precise brightness adjustment (1% steps):**
- `Alt + XF86MonBrightnessUp` - Increase brightness by 1%
- `Alt + XF86MonBrightnessDown` - Decrease brightness by 1%

### Technical Details

**Brightness Scale:**
- Maximum value: 96000 (device-specific)
- 1% = 960 units
- 5% = 4800 units

**Wrapper Script Features:**
- Prevents brightness from going below 1%
- Snaps values to multiples of 5
- Special case handling for 1% → 5% transition
- Displays OSD feedback via SwayOSD

**Files:**
- Script: `~/.local/share/omarchy/bin/omarchy-cmd-brightness`
- Bindings: `~/.local/share/omarchy/default/hypr/bindings/media.conf:9-10,15-16`

---

## Backup & Snapshot System

### Overview
Your system uses **Btrfs snapshots** with **Snapper** for instant, space-efficient backups. Snapshots are integrated with the **Limine bootloader**, allowing you to boot directly from any snapshot to restore your system.

### Technology Stack
- **Filesystem:** Btrfs (supports instant copy-on-write snapshots)
- **Snapshot Manager:** Snapper 0.13.0-2
- **Bootloader Integration:** Limine Snapper Sync 1.18.1-1
- **Boot Entries:** Up to 5 most recent snapshots appear in bootloader

### Snapshot Configurations
Two independent snapshot configs are active:

1. **root** - System snapshots (/)
   - Config file: `/etc/snapper/configs/root`
   - Snapshot location: `/.snapshots/`
   - Max snapshots: 5 regular + 5 important

2. **home** - Home directory snapshots (/home)
   - Config file: `/etc/snapper/configs/home`
   - Snapshot location: `/home/.snapshots/`
   - Max snapshots: 5 regular + 5 important

### Settings
- **Automatic timeline snapshots:** Disabled (manual only)
- **Number cleanup:** Enabled (keeps max 5 snapshots)
- **Space limit:** 50% of filesystem
- **Free space requirement:** 20% must remain free

### Commands

**Create a snapshot:**
```bash
omarchy-snapshot create
```
Creates numbered snapshots for both root and home configs.

**Restore from a snapshot:**
```bash
omarchy-snapshot restore
```
Opens bootloader menu to select and boot from a previous snapshot.

**View snapshots:**
```bash
sudo snapper -c root list    # View system snapshots
sudo snapper -c home list    # View home snapshots
sudo snapper list-configs    # View all configs
```

**Delete a snapshot:**
```bash
sudo snapper -c root delete <number>    # Delete system snapshot
sudo snapper -c home delete <number>    # Delete home snapshot
```

**Compare snapshots:**
```bash
sudo snapper -c root status <number1>..<number2>
sudo snapper -c root diff <number1>..<number2>
```

### Best Practices

**When to create snapshots:**
- Before major system updates (`pacman -Syu`)
- Before installing new software
- Before making system configuration changes
- Before experimenting with the system
- After successful major changes (mark as "important")

**Snapshot workflow:**
```bash
# Before making changes
omarchy-snapshot create

# Make your changes
sudo pacman -S some-package

# If something breaks, reboot and select snapshot from bootloader
# Or manually restore files from /.snapshots/<number>/snapshot/
```

### Recovery Process

**Option 1: Boot from snapshot (full system restore)**
1. Reboot your system
2. In the Limine bootloader, select "Snapshots"
3. Choose the snapshot you want to boot
4. System boots from the selected snapshot state

**Option 2: Restore individual files**
```bash
# Snapshots are accessible at /.snapshots/<number>/snapshot/
# Browse and copy files manually
sudo cp /.snapshots/42/snapshot/etc/some-config /etc/some-config
```

**Option 3: Full restore via command**
```bash
omarchy-snapshot restore
# Follow the prompts to select and restore a snapshot
```

### Monitoring Snapshots

**Check snapshot disk usage:**
```bash
sudo btrfs filesystem df /
sudo btrfs filesystem usage /
```

**View snapshot details:**
```bash
sudo snapper -c root list
# Shows: Type, Pre#, Date, User, Description
```

### Automation

The `limine-snapper-sync` service automatically:
- Updates bootloader entries when snapshots are created/deleted
- Maintains up to 5 snapshot entries in the boot menu
- Syncs on every kernel update or manual snapshot creation

---

## Running Processes

Top 50 processes by memory usage saved to: `~/running_processes.txt`

---

## File Locations

All documentation files are saved in your home directory:

- `~/system_documentation.md` - This comprehensive overview
- `~/installed_packages.txt` - All 1,156 packages
- `~/explicitly_installed_packages.txt` - 188 manually installed packages
- `~/pip_packages.txt` - 86 pip packages
- `~/running_processes.txt` - Top 50 processes by memory
- `~/services_running.txt` - 25 running services
- `~/services_enabled.txt` - 21 enabled services

