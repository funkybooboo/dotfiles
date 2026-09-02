# Dotfiles

Minimalist Arch Linux + Hyprland dotfiles, managed as ordered, idempotent
migrations.

## Quick start

```bash
git clone --recurse-submodules git@github.com:funkybooboo/dotfiles.git ~/dotfiles
cd ~/dotfiles
./migrate.sh              # install + configure everything
./migrate.sh --firmware   # also apply device firmware (fwupd); may reboot
# reboot into Hyprland
./setup.sh                # secrets, repos, NAS sync, project clone
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
| 5 | **flatpak** | Flathub. Proton Pass GUI (Proton's official Linux dist), Bottles, OrcaSlicer. |

**No AUR or yay.** Packages not in Arch official repos come from the
upstream release assets, then nix, then from source. Language runtimes
(rust, python, go, node, zig, bun) are managed globally by mise;
language-ecosystem packages (cargo, npm, pip, go, gem) are per-project only.

### nix usage

Nix itself is installed by `000011-nix` via the **upstream Nix installer**
(`releases.nixos.org`), NOT the Arch `extra/nix` pacman package -- the Arch
package links `libmimalloc` and crashes (SIGSEGV) on glibc ABI bumps. Update
nix itself with `nix upgrade-nix`; update flake packages as below.

```bash
nix profile add .#<pkg>       # install a package from the flake
nix profile upgrade --all      # upgrade all nix packages
nix flake update               # bump the nixpkgs pin (in ~/dotfiles/)
nix upgrade-nix               # upgrade nix itself (upstream installer)
```

## Repository layout

```
dotfiles/
|-- flake.nix         # nix packages (allowUnfree, pinned nixpkgs)
|-- flake.lock        # pinned nixpkgs revision
|-- migrate.sh        # preflight -> run migrations in order -> summary
|-- setup.sh          # post-reboot: secrets, repos, NAS, project clone/refresh
|-- migrations/       # NNNNNN-name.sh, idempotent, each owns one concern
|-- overlays/         # patches applied by flake.nix (e.g. waybar PR #5013)
|-- sources/          # git submodules built from source
\-- root/
    |-- home/         # -> $HOME (symlinked)
    \-- etc/          # -> /etc (copied with sudo)
```

`migrations/_common.sh` provides helpers: `install_pacman`, `install_nix`,
`install_flatpak`, `remove_flatpak`, `remove_pkg`, `link_file`, `link_tree`,
`link_dir`, `deploy_etc_file`, `enable_*_service`. Each migration
guard-sources `_common.sh` so it can run standalone. Conflicts back up to
`<dest>.bak.N`. There is no dry-run mode; to undo a run, see
[Snapshots and restore](#snapshots-and-restore).

## migrate.sh vs setup.sh

**`migrate.sh`** -- generic software install + upgrade. Knows nothing about
your repos, secrets, or containers. First run installs everything; re-running
upgrades all software to upstream-latest:

- `pacman -Syu` (system update)
- `nix profile upgrade --all` (nix packages)
- `mise upgrade` (language runtimes)
- `flatpak update` (flatpak apps)
- Proton Drive manifest roll-forward
- `000600` roll-forward: mise upgrade, nix profile upgrade --all, pi update,
  tldr cache refresh

**`setup.sh`** -- personal/environment management. Run after reboot (needs
browser + network). First run: Proton Pass login, Tailscale auth, NAS rsync
password, `secretmgr bootstrap`, SSH/GPG agent setup, GitHub SSH verification,
clone personal repos into `~/Projects`. Re-running: updates `~/Projects` repos,
syncs GitHub forks with upstream, rolls `sources/*` submodules forward and
rebuilds them, refreshes running Podman container images.

## Migrations

141 migrations grouped by concern. `ls migrations/` for the full list.

| Range | Concern |
|-------|---------|
| `000001`-`000082` | System, bootloader, kernels, nix, AppArmor, security (000040 hardened+LTS kernels; 000041 stock `linux` kernel as a gaming/Steam boot option -- the hardened LSM cmdline from 000051 breaks Steam's game<->client IPC pipe on this hardware, so the stock entry is added with a clean cmdline to replicate the omarchy environment) |
| `000100`-`000109` | Shell & editors |
| `000200`-`000236` | Dev tools (one migration per package -- split from former 000210-cli-utilities grab-bag; 000231-texlive bundles the TeX Live scheme metapackages as one ecosystem; 000232-smb bundles gvfs-smb+smbclient+cifs-utils as one SMB ecosystem; 000233-exercism the exercism CLI for exercism.nvim; 000234-codecrafters the codecrafters CLI; 000235-yazi the terminal file manager; 000236-worktrunk the `wt` git-worktree CLI for parallel AI agents, incl. its fish shell integration so `wt switch` can cd) |
| `000300`-`000325` | Desktop, Hyprland, browsers (firefox + chromium via pacman, brave via nix, librewolf + mullvad-browser via upstream release assets -- one migration per browser: 000303-firefox, 000309-chromium, 000313-brave, 000307-librewolf, 000308-mullvad-browser), audio, icon theme (000321 papirus-icon-theme), Hyprland hyprlang->Lua config migration (000322), espanso text expander (000325 -- Wayland build via nix, since Arch has no official package and upstream ships only a Debian .deb; needs the input group + a uinput udev rule for its EVDEV backend) |
| `000400`-`000420` | System services: power, bluetooth, network, ssh, firewall, btrfs, Vulkan drivers (000409, host 64-bit + 32-bit graphics stack: 64-bit for mpv/ffmpeg/GTK4/libplacebo, 32-bit required by pacman steam + Proton; enables [multilib], runs before 000510) |
| `000500`-`000577` | Apps: VPN, Tailscale, Proton Pass, Proton Drive, NAS sync, games, lazycsv, Ollama, caligula, Minecraft, rpi-imager, Discord, HandBrake, gcx (Grafana CLI), Bottles (Wine/flatpak), OrcaSlicer (native-linux slicer, replaces Windows-only Creality Slicer), OpenSCAD (coded 3D CAD modeller, pairs with OrcaSlicer for design-then-slice), VS Code (Microsoft editor, nix flake), waybar (nix flake, patched with upstream PR #5013 so the hyprland/workspaces module click works under Hyprland's Lua config), mupdf (lightweight PDF/XPS/EPUB viewer; ships mupdf.desktop so the pre-existing application/epub+zip default resolves), opencode (SST terminal AI coding agent, nix flake; free models available via OpenRouter free tier / Google AI Studio, no API key required), Heroic Games Launcher (Epic/GOG/Amazon game launcher, flatpak, downloads its own Wine-GE/Proton-GE runners) + desktop apps split one-per-package from former 000530-desktop-apps grab-bag |
| `000600` | Runtime roll-forward: mise, nix, pi, tldr |

`sudo` is a preflight prerequisite (not installed by a migration).

### Snapshots and restore

`migrate.sh` wraps the whole run in a snapper pre/post snapshot pair for `/` and
`/home`, taken after preflight and before the first migration. It **aborts if `/`
is not btrfs**: migrations rewrite the bootloader (`000020`), install kernels
(`000040`) and edit the kernel cmdline (`000051`), and the per-file
`<dest>.bak.N` copies cover none of that. Bypass with `DOTFILES_SKIP_SNAPSHOT=1`.

`000406-btrfs.sh` creates the `root` and `home` snapper configs and enables
`snapper-cleanup.timer` (without that timer, retention never runs). Retention is
`NUMBER_LIMIT=20`, roughly ten runs' worth of pairs. Hourly timeline snapshots
stay off -- these are on-demand snapshots, not a backup schedule.

The first run on a fresh machine cannot snapshot, since `000406` is what installs
snapper and it runs inside the loop being guarded. That run warns and continues;
later runs snapshot normally.

**See what a run changed**

```bash
sudo snapper -c root list                    # find the pre/post pair
sudo snapper -c root status <pre>..<post>    # changed paths
```

**Undo a run, machine still boots**

```bash
sudo snapper -c root undochange <pre>..<post>
```

**Undo a run, machine does not boot**

`snapper rollback` is not reliable here. It works by setting the btrfs default
subvolume, but this machine mounts `subvol=@` explicitly, which ignores it. Swap
the subvolume by hand:

1. Boot a live USB, unlock the LUKS container.
2. Mount the top level: `mount -o subvolid=5 /dev/mapper/<name> /mnt`
3. `mv /mnt/@ /mnt/@.broken`
4. Snapshot the good state back into place. The source path depends on where
   `/.snapshots` lives: `/mnt/@snapshots/<n>/snapshot` if it is its own
   subvolume, or `/mnt/@.broken/.snapshots/<n>/snapshot` if it is still a
   directory inside `@`.
   `btrfs subvolume snapshot <source> /mnt/@`
5. Reboot. Delete `@.broken` only once the restored system is confirmed good.

**Kernel or bootloader breakage**

`/boot` is FAT32, so no btrfs snapshot covers it. A rolled-back `@` restores
`/usr/lib/modules/*` while `/boot` keeps the newer UKI, and the two will not
match. Downgrade the kernel from the retained pacman cache (`@pkg`) instead:

```bash
sudo pacman -U /var/cache/pacman/pkg/<kernel>-<oldver>.pkg.tar.zst
```

Then confirm the UKI in `/boot` was actually regenerated --
`limine-mkinitcpio-hook` is deliberately not installed (see
`000020-bootloader.sh`), so this may need doing by hand.

**Prerequisite: `/.snapshots` should be its own subvolume**

Otherwise snapshots sit inside `@`, the subvolume you would roll back, and a
cleanup of `@.broken` takes them with it. `snapper create-config` normally
creates it as a subvolume, but it refuses when `/.snapshots` already exists as a
plain directory -- which is what the manual `btrfs-snapshot` script leaves
behind. Fixing it needs an `/etc/fstab` entry, which is machine-specific and not
deployed by migrations.

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
- **Profile:** minimal (not Hyprland -- migration owns it)
- **Network:** iwd + systemd-networkd (not NetworkManager)
- **Audio:** pipewire (migration installs it anyway)
- **Locale:** `en_US.UTF-8`

### Verify encryption before rebooting

```bash
cryptsetup luksDump /dev/nvme0n1p2
grep '^HOOKS' /etc/mkinitcpio.conf        # must contain 'encrypt'
grep cryptdevice /boot/limine/limine.conf  # must have cryptdevice=...:root
```

`/etc/crypttab` is not required for root encryption -- the initramfs `encrypt`
hook unlocks root via `cryptdevice=` in the kernel cmdline. `migrate.sh`
enforces these checks; override with `DOTFILES_ALLOW_UNENCRYPTED=1` if needed.

### Reboot checklist

- [ ] `systemctl is-enabled ufw greetd apparmor` -- all `enabled`
- [ ] `sudo grep apparmor=1 /boot/limine/limine.conf` -- both kernels
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

- `update-firmware` -- firmware updates via fwupd; opt-in through
  `./migrate.sh --firmware` because it can require a reboot. Logs to
  `~/.local/state/update-firmware.log`
- `clean-disk` -- orphans, caches, unused flatpaks
- `secretmgr` -- Proton Pass wrapper
- `sync-*` -- NAS sync (documents, music, photos, audiobooks, books)
- `vpn` -- VPN management

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

- **rkhunter egrep spam** -- cosmetic noise from a deprecated `/usr/bin/egrep`
  wrapper in a pacman hook. Harmless, not fixable without patching rkhunter.

## License

GPL -- see [LICENSE](LICENSE)
