# Repository contents

Layout of this repo and the scripts it installs.

## Repository layout

```
dotfiles/
|-- flake.nix         # nix packages (allowUnfree, pinned nixpkgs)
|-- flake.lock        # pinned nixpkgs revision
|-- migrate.sh        # preflight -> run migrations in order -> summary
|-- setup.sh          # post-reboot: secrets, repos, NAS, project clone/refresh
|-- migrations/       # NNNNNN-name.sh, idempotent, each owns one concern
|-- sources/          # git submodules built from source
\-- root/
    |-- home/         # -> $HOME (symlinked)
    |-- etc/          # -> /etc (copied with sudo)
    \-- usr/          # -> /usr (copied with sudo)
```

`migrations/_common.sh` provides helpers: `install_pacman`, `install_nix`,
`install_flatpak`, `remove_flatpak`, `remove_pkg`, `remove_nix`, `link_file`, `link_tree`,
`link_dir`, `deploy_etc_file`, `enable_*_service`. Each migration
guard-sources `_common.sh` so it can run standalone. Conflicts back up to
`<dest>.bak.N`. There is no dry-run mode; to undo a run, see
[Snapshots and restore](#snapshots-and-restore).

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

