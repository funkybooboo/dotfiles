# Dotfiles

Minimalist Arch Linux + Hyprland dotfiles, managed as ordered, idempotent
migrations.

## Quick start

```bash
git clone --recurse-submodules git@github.com:funkybooboo/dotfiles.git ~/dotfiles
cd ~/dotfiles
./migrate.sh        # install + configure everything
# reboot into Hyprland
./setup.sh          # secrets, repos, NAS sync, project clone
```

## Install priority

Software is installed in priority order from the first source that can
provide it. Each install is recorded in the migration that owns it.

| Tier | Source | What lives here |
|------|--------|-----------------|
| 1 | **pacman** | Arch official repos (core/extra/multilib), GPG-signed. Dominant tier. |
| 2 | **upstream release assets** | Prebuilt binaries or source tarballs published by the project itself on its GitHub/GitLab/Codeberg/etc. release page. sha256-verified against an upstream-published checksum file, GPG-verified where a release key exists (e.g. Mullvad Browser, LibreWolf, gcx, HandBrake). |
| 3 | **nix** | Local flake (`flake.nix`) wrapping nixpkgs with `allowUnfree = true`, pinned via `flake.lock`. Hermetic sandboxed builds, PR-reviewed, binary cache at cache.nixos.org. |
| 4 | **from source** | Clone the repo (or download a source tarball from the releases page) and build it. Used when no prebuilt binary is published.
| 5 | **flatpak** | Flathub (Proton Pass GUI -- Proton's official Linux dist). |
| 6 | **AppImage** | Self-contained single-file executables from upstream releases. |
| 7 | **snap** | Snap Store. |

**No AUR or yay.** Packages not in Arch official repos come from the
upstream release assets, then nix, then from source. Language runtimes
(rust, python, go, node, zig, bun) are managed globally by mise;
language-ecosystem packages (cargo, npm, pip, go, gem) are per-project only.

### nix usage

```bash
nix profile add .#<pkg>       # install a package from the flake
nix profile upgrade --all     # upgrade all nix packages
nix flake update              # bump the nixpkgs pin (in ~/dotfiles/)
```

## Repository layout

```
dotfiles/
├── flake.nix         # nix packages (allowUnfree, pinned nixpkgs)
├── flake.lock        # pinned nixpkgs revision
├── migrate.sh        # preflight → run migrations in order → summary
├── setup.sh          # post-reboot: secrets, repos, NAS, project clone/refresh
├── migrations/       # NNNNNN-name.sh, idempotent, each owns one concern
├── sources/          # git submodules built from source
└── root/
    ├── home/         # → $HOME (symlinked)
    └── etc/          # → /etc (copied with sudo)
```

`migrations/_common.sh` provides helpers: `install_pacman`, `install_nix`,
`install_flatpak`, `remove_flatpak`, `remove_pkg`, `link_file`, `link_tree`,
`link_dir`, `deploy_etc_file`, `enable_*_service`. Each migration
guard-sources `_common.sh` so it can run standalone. Conflicts back up to
`<dest>.bak.N`. No dry-run or restore mode.

## migrate.sh vs setup.sh

**`migrate.sh`** — generic software install + upgrade. Knows nothing about
your repos, secrets, or containers. First run installs everything; re-running
upgrades all software to upstream-latest:

- `pacman -Syu` (system update)
- `nix profile upgrade --all` (nix packages)
- `mise upgrade` (language runtimes)
- `flatpak update` (flatpak apps)
- Proton Drive manifest roll-forward
- `000600` roll-forward: mise upgrade, nix profile upgrade --all, pi update,
  tldr cache refresh

**`setup.sh`** — personal/environment management. Run after reboot (needs
browser + network). First run: Proton Pass login, Tailscale auth, NAS rsync
password, `secretmgr bootstrap`, SSH/GPG agent setup, GitHub SSH verification,
clone personal repos into `~/Projects`. Re-running: updates `~/Projects` repos,
syncs GitHub forks with upstream, rolls `sources/*` submodules forward and
rebuilds them, refreshes running Podman container images.

## Migrations

123 migrations grouped by concern. `ls migrations/` for the full list.

| Range | Concern |
|-------|---------|
| `000001`–`000082` | System, bootloader, kernels, nix, AppArmor, security |
| `000100`–`000109` | Shell & editors |
| `000200`–`000230` | Dev tools (one migration per package -- split from former 000210-cli-utilities grab-bag) |
| `000300`–`000320` | Desktop, Hyprland, browsers (firefox + chromium via pacman, brave via nix, librewolf + mullvad-browser via upstream release assets -- one migration per browser: 000303-firefox, 000309-chromium, 000313-brave, 000307-librewolf, 000308-mullvad-browser), audio |
| `000400`–`000420` | System services: power, bluetooth, network, ssh, firewall, btrfs |
| `000500`–`000569` | Apps: VPN, Tailscale, Proton Pass, Proton Drive, NAS sync, games, lazycsv, Ollama, caligula, Minecraft, rpi-imager, Discord, HandBrake, gcx (Grafana CLI) + desktop apps split one-per-package from former 000530-desktop-apps grab-bag |
| `000600` | Runtime roll-forward: mise, nix, pi, tldr |

`sudo` is a preflight prerequisite (not installed by a migration).

### Sources as git submodules

Repos built from source (`lazycsv`, `lazymusic`, the `99` nvim plugin) live
as git submodules under `sources/`. Clone with `--recurse-submodules` or rely
on `migrate.sh` preflight (`git submodule update --init --recursive --depth 1`).
Re-running `setup.sh` rolls submodules to upstream-latest and rebuilds them;
commit the resulting pointer bumps to pin new versions across machines.

**Not deployed by migrations** (machine-specific): `/etc/fstab`,
`/etc/crypttab`, `/etc/mkinitcpio.conf`, `/etc/hosts`.

**Deferred:** USBGuard, OpenSnitch.

## Fresh install (archinstall)

### Disk layout

| Mount | Size | Type | Encryption |
|-------|------|------|------------|
| `/boot` | 1 GiB | FAT32 | none |
| `/` | rest | btrfs | LUKS |

Btrfs subvolumes: `@` -> `/`, `@home` -> `/home`, `@log` -> `/var/log`,
`@pkg` -> `/var/cache/pacman/pkg`.

### archinstall options

- **Disk encryption:** YES
- **Filesystem:** btrfs, `zstd`
- **Bootloader:** Limine (or systemd-boot, then migrate to Limine)
- **Kernels:** `linux-lts` + `linux-hardened` (or just `linux-lts`)
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

`/etc/crypttab` is not required for root encryption — the initramfs `encrypt`
hook unlocks root via `cryptdevice=` in the kernel cmdline. `migrate.sh`
enforces these checks; override with `DOTFILES_ALLOW_UNENCRYPTED=1` if needed.

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

All secrets live in **Proton Pass**, accessed via `secretmgr`.

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

`secretmgr bootstrap` runs in `setup.sh`. SSH keys load into the agent on
login (`load_on_login = true` in `~/.config/secretmgr/config.toml`).

## Scripts

Migrations link scripts into `~/.local/bin/` and `~/.local/lib/`:

- `update-firmware` — firmware updates (reboot-gated, intentionally outside
  migrate.sh)
- `clean-disk` — orphans, caches, unused flatpaks
- `secretmgr` — Proton Pass wrapper
- `sync-*` — NAS sync (documents, music, photos, audiobooks, books)
- `vpn` — VPN management

Both `migrate.sh` and `setup.sh` mirror all output to `logs/` (gitignored):
`migrate-YYYYMMDD-HHMMSS-PID.log` and `setup-YYYYMMDD-HHMMSS-PID.log`.

## NAS sync

Timers run automatically after `setup.sh`. Manual sync:

```bash
systemctl --user start nas-sync-documents.service
journalctl --user -u nas-sync-documents.service -f
```

Synced dirs: `Documents`, `Music`, `Photos`, `Audiobooks`, `Books`.
Bidirectional with `--delete`.

## Back up before wiping

Not recoverable from dotfiles / NAS / Proton Pass:

| Item | Backup command |
|------|---------------|
| GPG secret key | `gpg --export-secret-keys --armor > gpg.asc` |
| GPG ownertrust | `gpg --export-ownertrust > ownertrust.txt` |
| Browser profiles | Browser sync, or copy `~/.librewolf` / `~/.config/brave` |
| Atuin history | `atuin sync` (cloud), or copy `~/.local/share/atuin` |
| pi sessions | `~/.pi/agent/sessions/` |

SSH keys are in Proton Pass `SSH` vault; `secretmgr ssh-add` reloads them
after a fresh install.

## Known issues

- **rkhunter egrep spam** — cosmetic noise from a deprecated `/usr/bin/egrep`
  wrapper in a pacman hook. Harmless, not fixable without patching rkhunter.

## License

GPL — see [LICENSE](LICENSE)
