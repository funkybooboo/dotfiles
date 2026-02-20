# Dotfiles

Minimalist Arch Linux dotfiles for a Hyprland/Omarchy desktop.

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
| `--skip-packages` | Skip package installation (symlinks/services only) |
| `--backup, -b` | Backup conflicting files with `.bak` suffix (creates `.bak` files) |
| `--force, -f` | Remove conflicting files/symlinks (destructive) |
| `--merge, -m` | Open nvim diff to merge conflicts — edit the **right pane** (dotfiles source), which is saved and symlinked (creates `.bak` files) |
| `--with-vpn` | Install WireGuard config to `/etc/wireguard/` |
| `--with-nas-sync` | Enable hourly NAS rsync timers |
| `--help, -h` | Show help message |

**Common invocations:**

```bash
./install.sh --dry-run                            # preview without changes
./install.sh --backup                             # fresh install
./install.sh --skip-packages --backup             # re-symlink only
./install.sh --backup --with-vpn --with-nas-sync  # full install
./install.sh --restore --dry-run                  # preview restore
./install.sh --restore                            # undo installation
```

## Structure

`root/` mirrors the filesystem — files symlink to where they land on disk.

```
dotfiles/
├── root/
│   ├── home/                       # → $HOME
│   │   ├── .config/
│   │   │   ├── fish/               # Fish shell
│   │   │   ├── hypr/               # Hyprland overrides
│   │   │   ├── nvim/               # Neovim plugins
│   │   │   ├── omarchy/            # Omarchy hooks, branding, extensions
│   │   │   ├── opencode/           # OpenCode AI config
│   │   │   └── systemd/            # User services (NAS sync, power, SSH agent)
│   │   ├── .local/
│   │   │   ├── bin/                # Custom scripts
│   │   │   ├── lib/                # Shared library scripts
│   │   │   └── share/omarchy/      # [submodule] funkybooboo/omarchy fork
│   │   ├── .gitconfig
│   │   ├── .vimrc
│   │   └── .ssh/config
│   └── etc/                        # → /etc
│       ├── hosts
│       └── udev/rules.d/
└── install.sh
```

**Scripts in `.local/bin`:**

| Script | Purpose |
|--------|---------|
| `update` | Full system update (yay + flatpak + omarchy + firmware) |
| `gg` | AI-powered git commit helper |
| `vpn` | VPN management (home / proton / usu) |
| `clean-disk` | System cleanup |
| `clean-memory` | Free up memory |
| `btrfs-snapshot` | Create BTRFS snapshots |
| `sync-*` | NAS sync (documents / music / photos / audiobooks / books) |

## NAS Sync (optional)

Run with `--with-nas-sync` to enable hourly rsync to your NAS. The script prompts for your rsync password, or set it manually:

```bash
echo 'your_password' > ~/.config/nas-sync/rsync-password
chmod 600 ~/.config/nas-sync/rsync-password
```

```bash
systemctl --user list-timers                        # check timer status
systemctl --user start nas-sync-documents.service   # manual sync
journalctl --user -u nas-sync-documents.service -f  # watch logs
```

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

## Submodule (Omarchy)

The Omarchy fork lives at `root/home/.local/share/omarchy/` and is symlinked as a whole directory so its `.git` stays intact.

```bash
# Update to latest fork commit
git submodule update --remote root/home/.local/share/omarchy
git add root/home/.local/share/omarchy
git commit -m "chore: advance omarchy submodule pin"

# Sync upstream omarchy changes into fork
cd root/home/.local/share/omarchy
git fetch https://github.com/basecamp/omarchy.git master
git merge FETCH_HEAD && git push
```

> The `update` script advances the submodule pin automatically after `omarchy-update` runs.

## Maintenance

```bash
update       # yay + flatpak + omarchy + firmware
clean-disk   # remove orphans, caches, unused flatpaks
```

## License

GPL — see [LICENSE](LICENSE)
