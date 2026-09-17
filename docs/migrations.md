# Migrations

What migrate.sh and setup.sh each own, and how the migrations they run are organized.

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

151 migrations grouped by concern. `ls migrations/` for the full list.

| Range | Concern |
|-------|---------|
| `000001`-`000083` | System, bootloader, kernels, nix, AppArmor, security (000040 hardened+LTS kernels; 000041 stock `linux` kernel as a gaming/Steam boot option -- the hardened LSM cmdline from 000051 breaks Steam's game<->client IPC pipe on this hardware, so the stock entry is added with a clean cmdline to replicate the omarchy environment; 000012 graphical-session-keeper -- a no-op BindsTo= oneshot that holds graphical-session.target up and sweeps retired user units, because the stock target is StopWhenUnneeded=yes + RefuseManualStart=yes and was held up only by hypr-wallpaper.service's BindsTo= side effect until quickshell retired it: the daemon-reload that landed while the deleted unit's enabled symlink still dangled stopped the whole graphical session mid-migrate, taking the terminal running migrate.sh with it; 000083 android-udev -- USB udev rules for Android devices, plus adbusers group membership, which is what makes the rules grant access without root) |
| `000100`-`000109` | Shell & editors |
| `000200`-`000239` | Dev tools (one migration per package -- split from former 000210-cli-utilities grab-bag; 000231-texlive bundles the TeX Live scheme metapackages as one ecosystem; 000232-smb bundles gvfs-smb+smbclient+cifs-utils as one SMB ecosystem; 000233-exercism the exercism CLI for exercism.nvim; 000234-codecrafters the codecrafters CLI; 000235-yazi the terminal file manager; 000236-worktrunk the `wt` git-worktree CLI for parallel AI agents, incl. its fish shell integration so `wt switch` can cd; 000237-herdr the agent multiplexer that keeps coding-agent terminals running across detach and reconnect -- nix flake, since Arch has no official package and AUR is excluded by policy; on `$mod+CTRL+Return`, keymap is a tmux-parity port from omarchy (`C-Space` prefix, splits/tabs/workspaces matching tmux.conf), runs from a `herdr.service` user unit instead of being daemonized into the spawning terminal's cgroup, plus the `hdl`/`hdlm`/`hsl` fish layout builders; 000239-presenterm the terminal slideshow tool, tier 1 since extra carries the same 0.16.1 the work repo gets from nixpkgs) |
| `000300`-`000328` | Desktop, Hyprland, browsers (firefox + chromium via pacman, brave via nix, librewolf + mullvad-browser via upstream release assets -- one migration per browser: 000303-firefox, 000309-chromium, 000313-brave, 000307-librewolf, 000308-mullvad-browser), LibreWolf tracked settings + webapps (000326 links a tracked user.js into the active profile -- discovered from profiles.ini [Install*] Default=, since profile names are machine-random and the legacy [Profile*] Default=1 marker can disagree; 000327 renders taskbar-tab webapp launcher templates with @PROFILE_DIR@ resolved to the local profile), audio, icon theme (000321 papirus-icon-theme), Hyprland hyprlang->Lua config migration (000322), espanso text expander (000325 -- Wayland build via nix, since Arch has no official package and upstream ships only a Debian .deb; needs the input group + a uinput udev rule for its EVDEV backend); quickshell (000328 -- the whole shell in one QML config: bar, tray, tooltips, notifications, wallpaper, application launcher, clipboard picker, window switcher and the volume/brightness keys, replacing waybar, mako, hyprlauncher, hyprpaper and a dozen shell scripts. hypridle and hyprlock are deliberately kept -- they have no bar overlap, and hypridle is also the logind bridge that locks on suspend, which quickshell cannot be. The `root/home/.config/quickshell/` tree matches the work repo's apart from the wallpaper filename and the Network button's command (impala here, nmtui there -- the same NetworkManager daemon either way, 000402), so only the migration differs otherwise: pacman here, a source build there. Interrogate the running shell with `quickshell ipc call shell status`) |
| `000400`-`000420` | System services: power, bluetooth, network, ssh, firewall, btrfs, Vulkan drivers (000402 NetworkManager with iwd as the wifi backend, so impala (000562) manages wifi and saved /var/lib/iwd networks keep connecting; systemd-networkd and its deployed .network files are retired here; 000409, host 64-bit + 32-bit graphics stack: 64-bit for mpv/ffmpeg/GTK4/libplacebo, 32-bit required by pacman steam + Proton; enables [multilib], runs before 000510) |
| `000500`-`000581` | Apps: VPN, Tailscale, Proton Pass, Proton Drive, NAS sync, games, lazycsv, Ollama, caligula, Minecraft, rpi-imager, Discord, HandBrake, gcx (Grafana CLI), Bottles (Wine/flatpak), OrcaSlicer (native-linux slicer, replaces Windows-only Creality Slicer), OpenSCAD (coded 3D CAD modeller, pairs with OrcaSlicer for design-then-slice), VS Code (Microsoft editor, nix flake), mupdf (lightweight PDF/XPS/EPUB viewer; ships mupdf.desktop so the pre-existing application/epub+zip default resolves), opencode (SST terminal AI coding agent, nix flake; free models available via OpenRouter free tier / Google AI Studio, no API key required), Heroic Games Launcher (Epic/GOG/Amazon game launcher, flatpak, downloads its own Wine-GE/Proton-GE runners), GE-Proton (GloriousEggroll's custom Proton build for the native pacman Steam; Tier 2 upstream release tarball, sha512-verified, extracted into ~/.steam/steam/compatibilitytools.d and rolled forward to upstream-latest on each run; older versions are kept so per-game tool pins keep working), gamescope (Valve's nested gaming micro-compositor from the Steam Deck; pacman; frame limiting, integer scaling, HDR; runs as a Wayland client window under Hyprland, e.g. `gamescope -f -W 1920 -H 1080 -- steam -tenfoot`), gamemode (Feral GameMode, pacman; gamemoderun wrapper in Steam launch options requests CPU/GPU perf modes for any game incl. Proton; D-Bus activated, no service; pairs with gamescope in launch options, install order 000579 -> 000580), steam launch options audit (000581: read-only per-migrate reminder listing installed games whose localconfig.vdf LaunchOptions are missing or lack the gamescope/gamemoderun wrapper, plus PROTON_LOG leftovers; Steam does not sync launch options between machines, so every run is the reminder) + desktop apps split one-per-package from former 000530-desktop-apps grab-bag |
| `000600` | Runtime roll-forward: mise, nix, pi, tldr |

`sudo` is a preflight prerequisite (not installed by a migration).

### Writing a migration

1. Create `migrations/NNNNNN-name.sh` -- next free number in the right concern
   range (table above). Mind ordering: migrations run in lexicographic order,
   so a migration may only depend on runtimes installed by lower-numbered ones.
2. Guard-source the helpers as the first line:
   `[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"`
3. Use only the `_common.sh` helpers -- never call `pacman`/`sudo`/`ln` directly:
   `install_pacman`, `install_nix`, `install_flatpak`, `remove_flatpak`,
   `remove_pkg`, `link_file`, `link_tree`, `link_dir`, `deploy_etc_file`,
   `enable_user_service`, `enable_system_service`, `enable_system_service_no_start`.
4. Be **idempotent**: re-running must be safe (check before installing, skip
   when already done). Conflicts are backup-only (`<dest>.bak.N`) -- no
   `--force`/`--merge`/dry-run/restore.
5. Be **non-fatal**: a single failure must not abort the run. Record problems
   with `_add_warning` / `_add_error` so they surface in the final summary.
   (`install_pacman`/`install_nix` already return 0 and warn on failure.)
6. Header comment: `# NNNNNN-name.sh -- <one-line summary>` followed by
   `# Installs:`, `# Links:`, `# Enables:`, `# Note:` lines, matching the
   existing style.
7. After writing: test it standalone (`bash migrations/NNNNNN-name.sh`)
   including the idempotent re-run path and the missing-dependency path;
   update the migration count in this README; `git add` + commit with a clear
   message; remind the user to re-run `./migrate.sh` on other machines (or note
   that the change replicates via the existing link helpers).

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

