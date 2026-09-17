# Dotfiles

Arch Linux + Hyprland, managed as ordered, idempotent migrations.

## Quick start

```bash
git clone --recurse-submodules git@github.com:funkybooboo/dotfiles.git ~/dotfiles
cd ~/dotfiles
./migrate.sh    # install and configure everything; safe to re-run
# reboot into Hyprland
./setup.sh      # secrets, project repos, NAS sync
```

Installing onto a bare machine instead? See [docs/install.md](docs/install.md).

## How it works

One migration per piece of software. Each `migrations/NNNNNN-*.sh` installs the
thing it owns and links the config it owns, and must be safe to re-run;
`migrate.sh` runs them in lexicographic order. Config under `root/home/` is
symlinked into `~/`, so editing a live file edits the repo and `git status`
reports real drift.

`migrate.sh` handles software and knows nothing about your accounts.
`setup.sh` is the part that needs secrets and network: vault login, cloning
project repos, NAS sync.

## Documentation

- [Install](docs/install.md) -- quick start, archinstall from scratch, what to back up first
- [Migrations](docs/migrations.md) -- how `migrate.sh` works, writing one, snapshots and rollback
- [Packages](docs/packages.md) -- which install tier to reach for, and when nix is the right one
- [Contents](docs/contents.md) -- repository layout and the scripts it ships
- [Secrets](docs/secrets.md) -- vault, `secretmgr`, what never lands in git
- [NAS and gaming](docs/nas_and_gaming.md) -- sync timers, Steam and Proton
- [Sibling repo](docs/sibling_repo.md) -- the work machine, what diverges on purpose, and `dotfiles-drift`

## License

GPL -- see [LICENSE](LICENSE)
