# Dotfiles

Minimalist Arch Linux dotfiles for a Hyprland desktop, managed as ordered,
idempotent migrations — like database migrations for your system.

## Quick Start

```bash
git clone git@github.com:funkybooboo/dotfiles.git ~/dotfiles
cd ~/dotfiles
./migrate.sh
```

`migrate.sh` runs every migration in `migrations/` in numeric order. Each
migration installs its packages, symlinks its configs, and enables its
services together. Migrations are idempotent — re-running `./migrate.sh` is
always safe. Conflicting files are backed up to `<dest>.bak.N` before being
replaced with a symlink.

After migrations finish, **reboot into Hyprland**, then run the interactive
secrets setup (needs a browser + network):

```bash
./setup-secrets.sh
```

## How it works

```
dotfiles/
├── migrate.sh              # Orchestrator: preflight → source migrations in order → summary
├── setup-secrets.sh        # Post-reboot interactive: Proton Pass + Tailscale login, NAS sync
├── migrations/
│   ├── _common.sh          # Shared helpers (install/link/enable/output) + globals
│   └── NNNNNN-name.sh      # One migration per concern, run in lexicographic order
└── root/                   # Source-of-truth tree (untouched by migrations)
    ├── home/               # → $HOME  (symlinked)
    └── etc/                # → /etc   (copied with sudo)
```

- **`root/`** is the source of truth. Migrations symlink `root/home/**` into
  `$HOME` and copy `root/etc/**` into `/etc`. `root/` itself is never modified.
- **`migrations/_common.sh`** provides shared helpers: `install_pacman`,
  `install_aur`, `link_file`/`link_tree`/`link_dir`, `deploy_etc_file`,
  `enable_user_service`/`enable_system_service`, and output helpers. Every
  migration guard-sources it so it can also run standalone.
- **Each migration** has a header documenting what it installs, links, and
  enables. Migrations are numbered with 6 digits and gaps for future inserts.
- **No arguments.** `./migrate.sh` just runs everything. Conflicts resolve by
  backing up the existing file. There is no dry-run, force, merge, or restore
  mode.

### `setup-secrets.sh`

Run **after** `./migrate.sh` and a reboot into Hyprland (it needs a desktop
browser and network). It handles everything interactive/secret-dependent that
shouldn't run in a fresh TTY:

1. Proton Pass (`pass-cli`) login
2. Tailscale authentication (`tailscale up`)
3. NAS rsync password (from Proton Pass, or prompted)
4. `secretmgr bootstrap` (inject secrets into templated configs)
5. NAS initial clone (Documents, Music, Photos, Audiobooks, Books)
6. Ensure NAS sync timers are enabled

## Migrations

118 migrations across foundation, shell/editors, dev, desktop, system services,
and apps. Run in order by `migrate.sh`:

| Range | Group |
|-------|-------|
| `000001`–`000090` | System update, base, bootloader, boot/disk, kernels, AppArmor, security scanners, hosts |
| `000100`–`000109` | Shell & editors: bash, fish, starship, atuin, tmux, bat, btop, ripgrep, neovim, vim |
| `000200`–`000229` | Dev: git, lazygit, mise, python, podman, lazydocker, pi-agent, act + CLI tools (fzf, fd, eza, …) |
| `000300`–`000325` | Desktop: fonts, flatpak, ghostty, browsers, pipewire, mpv, obs, Hyprland ecosystem, Wayland utilities |
| `000400`–`000420` | System services: power, bluetooth, network, ssh, gnupg, firewall, btrfs, earlyoom, fwupd, sudo, zram |
| `000500`–`000545` | Apps: calcure, television, steam, virtualization, VPN, tailscale, proton-pass, secretmgr, nas-sync, monero, GUI apps |

Each file is named after what it does. To see the full list:

```bash
ls migrations/
```

### Deferred / disabled

- **USBGuard + OpenSnitch** (`000060`) — intentionally not installed or linked;
  will be added as a new migration at a later date. The `~/.config/usbguard`
  config sits in `root/` ready for when it's re-enabled.
- **cups / printing** — dropped entirely (no printing needed).
- **opencode** — dropped (replaced by the pi coding agent).

## Secrets

All secrets live in **Proton Pass** and are accessed via `secretmgr`
(`~/.local/bin/secretmgr`) — a wrapper around `pass-cli`. Config at
`~/.config/secretmgr/config.toml`.

| Command | Purpose |
|---------|---------|
| `secretmgr init` | Install pass-cli, login, create vaults |
| `secretmgr status` | Check Proton Pass session |
| `secretmgr add <vault/item> KEY=val...` | Add/update a secret |
| `secretmgr get <vault/item> [FIELD]` | Get a secret value |
| `secretmgr copy <vault/item> FIELD` | Copy to clipboard (auto-clears 45s) |
| `secretmgr list [vault]` | List secrets |
| `secretmgr delete <vault/item>` | Delete a secret |
| `secretmgr inject <template> <output>` | Replace `{{ secret:vault/item/field }}` placeholders |
| `secretmgr env [vault]` | Print eval-able shell exports |
| `secretmgr bootstrap` | Deploy all secrets + render templates to this machine |
| `secretmgr ssh-add` | Load SSH keys from Proton Pass `SSH` vault into systemd ssh-agent |

**Vault aliases** (short name → Proton Pass vault): `nas`, `api`, `ssh`, `gpg`,
`home`, `services`, `subscriptions`, `identity`, `gaming`, `school`, `projects`,
`apply`, `finance`, `aws`.

`secretmgr bootstrap` runs in `setup-secrets.sh` after the Proton Pass login.
SSH keys load into the agent on login (`load_on_login = true` in config.toml).

Because secrets are stored in Proton Pass (cloud), a fresh OS install recovers
them via `setup-secrets.sh` — no local secret files need backing up.

Examples:

```bash
secretmgr get nas/rsync password              # NAS rsync password
secretmgr add API/OpenCode api_key=sk-xxx      # add a secret
eval $(secretmgr env API)                      # load secrets as env vars
```

## Scripts in `.local/bin`

Linked by the migration that owns each script (not a single grab-bag):

| Script | Owner migration | Purpose |
|--------|-----------------|---------|
| `update` | personal-admin-scripts | Full system update (yay + flatpak + firmware) |
| `update-firmware` | personal-admin-scripts | fwupd firmware refresh |
| `gg` | personal-admin-scripts | AI-powered git commit helper |
| `vpn` | proton-vpn | VPN management |
| `secretmgr` | secretmgr | Proton Pass CLI wrapper |
| `backup` | personal-admin-scripts | System backup driver |
| `btrfs-snapshot` | personal-admin-scripts | Create BTRFS snapshots |
| `clean-disk` | personal-admin-scripts | Remove orphans, caches, unused flatpaks |
| `clean-memory` | personal-admin-scripts | Free up memory |
| `cleanup-audit` | personal-admin-scripts | Trim audit logs |
| `cleanup-system` | personal-admin-scripts | Broader system cleanup |
| `package-cleanup` | personal-admin-scripts | pacman orphan cleanup |
| `hot-procs` | personal-admin-scripts | Show CPU-heavy processes |
| `calendar-tui` | personal-admin-scripts | calcure launcher |
| `hypr-keybinds` | hyprland | List active Hyprland keybindings |
| `hypr-kill-workspace` | hyprland | Close all windows on a workspace |
| `hypr-lid-switch` | hyprland | Handle laptop lid events |
| `hypr-toggle-display` | hyprland | Toggle internal/external display |
| `theme-switch` | hyprland | Light/dark theme toggle |
| `nightmode-toggle` | hyprland | Night light toggle |
| `power-mode-menu` | power-management | Switch power profile |
| `screencast` | hyprland | Screen recording |
| `screenshot` | hyprland | Screenshot utility |
| `recording-indicator` | hyprland | Recording status indicator |
| `clipboard-manager` | hyprland | Cliphist wrapper |
| `toggle-lock` | hyprland | Manual lock trigger |
| `docker` / `docker-compose` | podman | Container helpers |
| `sync-*` | nas-sync | NAS sync (documents / music / photos / audiobooks / books) |

Shared helpers in `.local/lib/`:

| Lib | Owner migration | Purpose |
|-----|-----------------|---------|
| `sync-to-nas` | nas-sync | Bidirectional rsync core used by all `sync-*` scripts |
| `check-nas-connection` | nas-sync | Tailscale/host reachability probe |
| `good-time-to-run` | nas-sync | Time-of-day gating for background jobs |
| `power-profile-switch` | power-management | udev-triggered power profile change |
| `battery-notify` | power-management | Low battery notifications |

## NAS Sync

The `nas-sync` migration (`000525`) links the sync units, scripts, and timers
and enables the timers. The rsync **password** and **initial clone** happen in
`setup-secrets.sh` (need Proton Pass login + network).

Set the password manually if needed:

```bash
echo 'your_password' > ~/.config/nas-sync/rsync-password
chmod 600 ~/.config/nas-sync/rsync-password
```

Manage timers:

```bash
systemctl --user list-timers 'nas-sync-*'                 # status
systemctl --user start nas-sync-documents.service         # manual sync
journalctl --user -u nas-sync-documents.service -f        # watch logs
```

Synced dirs: `Documents`, `Music`, `Photos`, `Audiobooks`, `Books`.
Bidirectional with `--delete` — deletes propagate both ways.

## What dotfiles does NOT back up

`.gitignore` deliberately excludes keys, credentials, caches, and
machine-specific state. **Before wiping a drive**, back these up separately:

| Item | Path | Notes |
|------|------|-------|
| SSH private key | `~/.ssh/id_ed25519` | Canonical store is Proton Pass `SSH` vault — `secretmgr ssh-add` reloads after fresh install |
| GPG secret key | `~/.gnupg/private-keys-v1.d/` | `gpg --export-secret-keys --armor > backup.asc`; store in Proton Pass `GPG` vault or NAS |
| GPG ownertrust | `~/.gnupg/trustdb.gpg` | `gpg --export-ownertrust > ownertrust.txt` |
| NAS rsync password | `~/.config/nas-sync/rsync-password` | Recoverable via `secretmgr get nas/rsync password` |
| Browser profiles | `~/.librewolf`, `~/.mozilla` | Bookmarks, logins, history — use browser sync or manual copy |
| Shell history DB | `~/.local/share/atuin/` | `atuin sync` if cloud sync configured |
| pi agent sessions | `~/.pi/agent/sessions/` | Local-only conversation history |

## Maintenance

```bash
update       # yay + flatpak + firmware
clean-disk   # remove orphans, caches, unused flatpaks
```

## License

GPL — see [LICENSE](LICENSE)
