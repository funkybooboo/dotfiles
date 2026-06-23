# Dotfiles

Minimalist Arch Linux dotfiles for a Hyprland desktop.

## Quick Start

```bash
git clone git@github.com:funkybooboo/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --backup
```

`install.sh` handles packages, symlinks, permissions, and services in one shot.

## Flags

| Flag | Description |
|------|-------------|
| `--restore, -r` | Undo installation by restoring `.bak` files and removing symlinks |
| `--dry-run, -n` | Preview all actions without executing |
| `--backup, -b` | Backup conflicting files with `.bak` suffix (creates `.bak` files) |
| `--force, -f` | Remove conflicting files/symlinks (destructive) |
| `--merge, -m` | Open nvim diff to merge conflicts — edit the **right pane** (dotfiles source), which is saved and symlinked (creates `.bak` files) |
| `--help, -h` | Show help message |

**Common invocations:**

```bash
./install.sh --dry-run           # preview without changes
./install.sh --backup            # fresh install (recommended)
./install.sh --restore --dry-run # preview restore
./install.sh --restore           # undo installation
```

## Structure

`root/` mirrors the filesystem — files symlink to where they land on disk.

```
dotfiles/
├── installers/                     # Numbered package/setup scripts (00–30)
├── root/
│   ├── home/                       # → $HOME
│   │   ├── .config/
│   │   │   ├── atuin/              # Shell history sync
│   │   │   ├── bat/                # Syntax-highlighting cat
│   │   │   ├── btop/               # System monitor
│   │   │   ├── calcure/            # Calendar TUI
│   │   │   ├── fish/               # Fish shell
│   │   │   ├── ghostty/            # Terminal
│   │   │   ├── hypr/               # Hyprland (env, monitors, bindings, autostart, watchdog)
│   │   │   ├── lazygit/            # Git TUI
│   │   │   ├── mise/               # Runtime version manager
│   │   │   ├── mpv/                # Media player
│   │   │   ├── nvim/               # Neovim (lazy.nvim + per-language plugins)
│   │   │   ├── ripgrep/            # rg config
│   │   │   ├── secretmgr/          # Secret templates
│   │   │   ├── starship/           # Shell prompt
│   │   │   ├── systemd/            # User services (NAS sync, power, SSH agent, watchdogs)
│   │   │   ├── television/         # fuzzy finder TUI
│   │   │   ├── tmux/               # Terminal multiplexer
│   │   │   ├── walker/             # App launcher
│   │   │   ├── waybar/             # Status bar
│   │   │   └── wiremix/            # WirePlumber mixer
│   │   ├── .local/
│   │   │   ├── bin/                # Custom scripts (see table below)
│   │   │   ├── lib/                # Shared library scripts
│   │   │   └── share/applications/ # .desktop entries
│   │   ├── .pi/agent/              # pi coding agent extensions + skills
│   │   ├── .gitconfig
│   │   ├── .gnupg/                 # gpg.conf + agent.conf (keys gitignored)
│   │   └── .ssh/config             # SSH config (keys gitignored)
│   └── etc/                        # → /etc
│       ├── audit/                  # auditd hardening rules
│       ├── crypttab, fstab, mkinitcpio.conf   # Disk + initramfs
│       ├── hosts, rkhunter.conf
│       ├── libvirt/                # VM network
│       ├── modprobe.d/             # btusb blocklist
│       ├── pacman.d/hooks/         # rkhunter auto-update hook
│       ├── profile.d/              # libvirt env
│       ├── sysctl.d/               # userns + hardening + swappiness
│       ├── systemd/system/         # rkhunter/chkrootkit scan timers
│       └── udev/rules.d/           # Power profile on plug/unplug
└── install.sh
```

## Installers

Numbered, sourced in order by `install.sh`:

| # | Script | Purpose |
|---|--------|---------|
| 00 | system-update | Full pacman/yay/flatpak update |
| 01 | core-packages | Base utilities |
| 02 | security-kernels | Hardened kernel + linux-hardened headers |
| 03 | apparmor | AppArmor profiles + service |
| 04 | application-security | USBGuard + OpenSnitch — **currently disabled** |
| 05 | intrusion-detection | rkhunter + chkrootkit timers |
| 06 | shell-utilities | fish, starship, atuin, bat, btop, tmux, television |
| 07 | dev-tools | Build toolchains + language tooling |
| 08 | hyprland-wayland | Hyprland + waybar + launchers |
| 09 | fonts | JetBrains, Nerd Fonts |
| 10 | flatpak | Flatpak + flathub |
| 11 | terminal-emulators | ghostty, etc. |
| 12 | browsers | LibreWolf, etc. |
| 13 | audio-video | pipewire, mpv |
| 14 | productivity | obsidian, etc. |
| 15 | finance | beancount tooling |
| 16 | system-utilities | misc system tools |
| 17 | gaming | steam, lutris |
| 18 | virtualization | libvirt, docker |
| 20 | vpn | WireGuard/OpenVPN |
| 21 | tailscale | Mesh VPN |
| 22 | proton-pass | `pass-cli` secret manager |
| 23 | nas-sync | NAS sync config dir + rsync password |
| 24 | desktop-apps | GUI apps |
| 25 | etc-files | /etc configs (hosts, fstab, sysctl, udev) |
| 26 | security-hardening | sysctl + audit rules |
| 27 | symlinks | Symlink root/ into place |
| 28 | permissions | .ssh, .gnupg perms |
| 29 | systemd-services | Enable user + system units |
| 30 | late-setup | secretmgr bootstrap + initial NAS sync |

### Disabled modules

- **`04-application-security.sh`** — USBGuard + OpenSnitch install + enable commented out for OS reinstall. Autostart entries in `hypr/autostart.conf` also commented. `watchdog-services.sh` retained but not invoked. Re-enable by uncommenting the blocks in both files.

## Scripts in `.local/bin`

| Script | Purpose |
|--------|---------|
| `update` | Full system update (yay + flatpak + firmware) |
| `update-firmware` | fwupd firmware refresh |
| `gg` | AI-powered git commit helper |
| `vpn` | VPN management (home / proton / usu) |
| `secretmgr` | Secret retrieval helper |
| `backup` | System backup driver |
| `btrfs-snapshot` | Create BTRFS snapshots |
| `clean-disk` | Remove orphans, caches, unused flatpaks |
| `clean-memory` | Free up memory |
| `cleanup-audit` | Trim audit logs |
| `cleanup-system` | Broader system cleanup |
| `package-cleanup` | pacman orphan cleanup |
| `hot-procs` | Show CPU-heavy processes |
| `hypr-keybinds` | List active Hyprland keybindings |
| `hypr-kill-workspace` | Close all windows on a workspace |
| `hypr-lid-switch` | Handle laptop lid events |
| `hypr-toggle-display` | Toggle internal/external display |
| `theme-switch` | Light/dark theme toggle |
| `nightmode-toggle` | Night light toggle |
| `power-mode-menu` | Switch power profile |
| `screencast` | Screen recording |
| `screenshot` | Screenshot utility |
| `recording-indicator` | Recording status indicator |
| `clipboard-manager` | Cliphist wrapper |
| `calendar-tui` | calcure launcher |
| `docker` / `docker-compose` | Container helpers |
| `toggle-lock` | Manual lock trigger |
| `sync-*` | NAS sync (documents / music / photos / audiobooks / books) |

Shared helpers in `.local/lib/`:

| Lib | Purpose |
|-----|---------|
| `sync-to-nas` | Bidirectional rsync core used by all `sync-*` scripts |
| `check-nas-connection` | Tailscale/host reachability probe |
| `good-time-to-run` | Time-of-day gating for background jobs |
| `power-profile-switch` | udev-triggered power profile change |
| `battery-notify` | Low battery notifications |

## NAS Sync

Automatic — no flag needed. Installer `23-nas-sync.sh` creates `~/.config/nas-sync/` and sets the rsync password (from Proton Pass if `pass-cli` is available, else prompts). Installer `30-late-setup.sh` enables the five hourly timers and runs an initial sync.

Set the password manually if needed:

```bash
echo 'your_password' > ~/.config/nas-sync/rsync-password
chmod 600 ~/.config/nas-sync/rsync-password
```

Manage timers:

```bash
systemctl --user list-timers 'nas-sync-*'     # status
systemctl --user start nas-sync-documents.service   # manual sync
journalctl --user -u nas-sync-documents.service -f  # watch logs
```

Synced dirs: `Documents`, `Music`, `Photos`, `Audiobooks`, `Books`. Bidirectional with `--delete` — deletes propagate both ways.

## What dotfiles does NOT back up

`.gitignore` deliberately excludes keys, credentials, caches, and machine-specific state. **Before wiping a drive**, back these up separately:

| Item | Path | Notes |
|------|------|-------|
| SSH private key | `~/.ssh/id_ed25519` | Re-export to NAS/USB; update authorized_keys |
| GPG secret key | `~/.gnupg/private-keys-v1.d/` | `gpg --export-secret-keys --armor > backup.asc` |
| GPG ownertrust | `~/.gnupg/trustdb.gpg` | `gpg --export-ownertrust > ownertrust.txt` |
| NAS rsync password | `~/.config/nas-sync/rsync-password` | Recoverable via Proton Pass (vault: `NAS`, item: `rsync`) |
| Browser profiles | `~/.librewolf`, `~/.mozilla` | Bookmarks, logins, history — use browser sync or manual copy |
| Shell history DB | `~/.local/share/atuin/` | `atuin sync` if cloud sync configured |
| pi agent sessions | `~/.pi/agent/sessions/` | Local-only conversation history |

## Restore

Undo the installation by restoring `.bak` files and removing symlinks:

```bash
./install.sh --restore --dry-run  # preview what would be restored
./install.sh --restore            # restore backups and remove symlinks
```

**How it works:**
- Finds all symlinks pointing to `~/dotfiles/root/`
- Checks for corresponding `.bak` files
- Removes symlinks and restores `.bak` files in their place
- Deletes `.bak` files after successful restore
- Handles `/etc/hosts` and `/etc/udev` rules (requires sudo)

**Requirements:**
- Only works if you used `--backup` or `--merge` during installation (both create `.bak` files)
- `--force` does NOT create backups, so `--restore` won't find anything to restore

## Maintenance

```bash
update       # yay + flatpak + firmware
clean-disk   # remove orphans, caches, unused flatpaks
```

## License

GPL — see [LICENSE](LICENSE)
