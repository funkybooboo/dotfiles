# Dotfiles

Minimalist Arch Linux dotfiles for a Hyprland desktop, managed as ordered,
idempotent migrations.

## Fresh install (archinstall)

Install with these options so `./migrate.sh` applies cleanly:

### Disk layout

| Mount | Size | Type | Encryption |
|-------|------|------|------------|
| `/boot` | 1 GiB | FAT32 | **none** |
| `/` | rest | btrfs | **LUKS** |

Btrfs subvolumes: `@` → `/`, `@home` → `/home`, `@log` → `/var/log`, `@pkg` → `/var/cache/pacman/pkg`.

### archinstall options

- **Disk encryption:** YES
- **Filesystem:** btrfs, `zstd`
- **Bootloader:** Limine (or systemd-boot, then migrate to Limine)
- **Kernels:** `linux-lts` + `linux-hardened` (or just `linux-lts`, migration adds hardened)
- **Swap:** zram
- **User:** `nate`, sudo, **shell = bash** (migration sets fish later)
- **Profile:** minimal (not Hyprland — migration owns it)
- **Network:** iwd + systemd-networkd (not NetworkManager)
- **Audio:** pipewire (migration installs it anyway)
- **Locale:** `en_US.UTF-8`

### Verify encryption before rebooting

```bash
cryptsetup luksDump /dev/nvme0n1p2
grep '^HOOKS' /etc/mkinitcpio.conf        # must contain 'encrypt'
grep cryptdevice /boot/limine/limine.conf  # must have cryptdevice=...:root
```

`/etc/crypttab` is **not** required for root encryption — the initramfs `encrypt`
hook unlocks root via `cryptdevice=` in the kernel cmdline. `migrate.sh` enforces
these checks; override with `DOTFILES_ALLOW_UNENCRYPTED=1` if needed.

### After archinstall

```bash
git clone git@github.com:funkybooboo/dotfiles.git ~/dotfiles
cd ~/dotfiles
./migrate.sh
```

Then **reboot into Hyprland** and run:

```bash
./setup.sh
```

## How it works

```
dotfiles/
├── migrate.sh        # preflight → run migrations in order → summary
├── setup.sh          # post-reboot: Proton Pass, Tailscale, SSH, NAS sync, projects
├── migrations/       # NNNNNN-name.sh, idempotent, each owns one concern
└── root/
    ├── home/         # → $HOME (symlinked)
    └── etc/          # → /etc (copied with sudo)
```

- `migrations/_common.sh` provides helpers: `install_pacman`, `install_aur`,
  `link_file`, `link_tree`, `link_dir`, `deploy_etc_file`, `enable_*_service`.
- Each migration guard-sources `_common.sh` so it can run standalone.
- No arguments. Conflicts back up to `<dest>.bak.N`. No dry-run or restore mode.

### `setup.sh`

Run after reboot. Handles Proton Pass login, Tailscale auth, NAS rsync
password, `secretmgr bootstrap`, agent setup (loading the SSH key into
ssh-agent with a terminal passphrase prompt, and priming the GPG agent's
passphrase cache via pinentry-qt so git signed commits don't prompt for 8h),
GitHub SSH verification, switching the dotfiles remote to SSH, cloning
personal repos into `~/Projects` (from `~/.config/dotfiles/projects-repos.txt`),
and the initial NAS clone.

## Migrations

81 migrations grouped by concern. `ls migrations/` for the full list.

| Range | Concern |
|-------|---------|
| `000001`–`000082` | System, bootloader, kernels, AppArmor, security |
| `000100`–`000109` | Shell & editors |
| `000200`–`000210` | Dev tools |
| `000300`–`000320` | Desktop, Hyprland, browsers, audio |
| `000400`–`000420` | System services: power, bluetooth, network, ssh, firewall, btrfs |
| `000500`–`000552` | Apps: VPN, Tailscale, Proton Pass, Proton Drive CLI, NAS sync, games, lazycsv, Ollama, caligula, Minecraft launcher, rpi-imager (+GUI wrapper), AUR-debug cleanup, Discord, HandBrake (built from upstream source) |

`sudo` is asserted as a preflight prerequisite — not installed by a migration.

**Not deployed by migrations** (too machine-specific): `/etc/fstab`,
`/etc/crypttab`, `/etc/mkinitcpio.conf`, `/etc/hosts`. On an existing install,
these are already correct.

**Deferred:** USBGuard, OpenSnitch (not yet implemented).

### Reboot checklist

- [ ] `systemctl is-enabled ufw greetd apparmor` — all `enabled`
- [ ] `sudo grep apparmor=1 /boot/limine/limine.conf` — both kernels
- [ ] `./setup.sh` (after reboot)

After reboot:

```bash
systemctl is-active apparmor
sudo aa-status | head
```

## Secrets

All secrets live in **Proton Pass**, accessed via `secretmgr` (`pass-cli` wrapper).

| Command | Purpose |
|---------|---------|
| `secretmgr init` | Install pass-cli, login |
| `secretmgr get <vault/item> [FIELD]` | Get a secret |
| `secretmgr add <vault/item> KEY=val...` | Add/update |
| `secretmgr copy <vault/item> FIELD` | Copy to clipboard (45s auto-clear) |
| `secretmgr bootstrap` | Deploy all secrets + render templates |
| `secretmgr ssh-add` | Load SSH keys from Proton Pass `SSH` vault |

Vault aliases: `nas`, `api`, `ssh`, `gpg`, `home`, `services`, `subscriptions`,
`identity`, `gaming`, `school`, `projects`, `apply`, `finance`, `aws`.

`secretmgr bootstrap` runs in `setup.sh`. SSH keys load into the agent
on login (`load_on_login = true` in `~/.config/secretmgr/config.toml`).

## Scripts

Migrations link their own scripts into `~/.local/bin/` and `~/.local/lib/`.
Key ones:

- `update` — yay + flatpak + firmware
- `clean-disk` — orphans, caches, unused flatpaks
- `secretmgr` — Proton Pass wrapper
- `sync-*` — NAS sync (documents, music, photos, audiobooks, books)
- `vpn` — VPN management

## NAS Sync

Timers run automatically after `setup.sh`. Manual sync:

```bash
systemctl --user start nas-sync-documents.service
journalctl --user -u nas-sync-documents.service -f
```

Synced dirs: `Documents`, `Music`, `Photos`, `Audiobooks`, `Books`.
Bidirectional with `--delete`.

## Back up before wiping

These are NOT recoverable from dotfiles / NAS / Proton Pass:

| Item | Backup command |
|------|---------------|
| GPG secret key | `gpg --export-secret-keys --armor > gpg.asc` |
| GPG ownertrust | `gpg --export-ownertrust > ownertrust.txt` |
| Browser profiles | Browser sync, or copy `~/.librewolf` / `~/.config/brave` |
| Atuin history | `atuin sync` (cloud), or copy `~/.local/share/atuin` |
| pi sessions | `~/.pi/agent/sessions/` |

SSH keys are stored in Proton Pass `SSH` vault; `secretmgr ssh-add` reloads
them after a fresh install.

## Known issues

- **Remaining `install_aur` calls** — a handful of migrations still call
  `install_aur` for packages NOT in the off-AUR scope (because they are not
  currently installed): `greetd-tuigreet`, `tectonic`, `lazygit`, `mise`,
  `ghostty`, `wiremix`, `uwsm`, `nwg-displays`, `zram-generator`,
  `television`, `proton-vpn-cli`/`proton-vpn-gtk-app`, `lazydocker`, `act`,
  `gum`, `signal-desktop`. Re-running `migrate.sh` may install these via yay.
  Address each (official repo / flatpak / local PKGBUILD / drop) when ready.
- **tdf needs nightly Rust** — built from source via a local PKGBUILD; the
  `000210` migration runs `rustup toolchain install nightly` (rustup is the
  official Rust toolchain manager, rust-lang.org — not a registry).
- **calcure + mermaid-cli intentionally kept** on AUR/npm per user decision
  (the only PyPI-only / npm-only holdouts).
- **rkhunter egrep spam** — cosmetic noise from a deprecated `/usr/bin/egrep`
  wrapper in a pacman hook. Harmless, not fixable without patching rkhunter.

## License

GPL — see [LICENSE](LICENSE)
