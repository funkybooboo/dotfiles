# dotfiles

This repository manages your personal dotfiles, NixOS system configuration, and utility scripts using [GNU Stow]. It:

- **Keeps** your home-directory dotfiles neatly organized into Stow packages  
- **Deploys** your NixOS `configuration.nix` into `/etc/nixos`  
- **Backs up** any conflicting files before linking  
- **Registers** custom scripts (e.g. `rebuild`, `update`) into `~/.local/bin`

---

## 📦 Repository Layout

```
.
├── bash/                   # ~/.bashrc
├── config/.config/…        # ~/.config/*
├── etc/nixos/              # /etc/nixos/configuration.nix
├── gdbinit/                # ~/.gdbinit
├── ideavim/                # ~/.ideavimrc
├── scripts/.scripts/…      # ~/.scripts/*
├── vim/                    # ~/.vimrc
├── config.json             # List of scripts to add to PATH
├── shell.nix               # nix-shell environment (stow, jq)
└── setup.sh                # orchestrates backups, stow, script registration
```

---

## 🚀 Quick Start

### 1. Clone

```bash
git clone https://your.git.repo/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Enter Development Shell

This brings in `stow` and `jq` automatically:

```bash
nix-shell
```

You’ll see:

```
🛠  Entered nix-shell with stow and jq available
```

### 3. Preview Changes (Dry-Run)

Before touching anything, simulate the full workflow:

```bash
./setup.sh --dry-run
```

You should see “DRY RUN:” messages, the Stow links that _would_ be created, and any backups that _would_ occur.

### 4. Apply for Real

If the dry-run looks good, run:

```bash
./setup.sh
```

- **One sudo prompt** up front  
- Conflicting files moved to `~/dotfiles/stow-backups/<timestamp>/…`  
- Home dotfiles linked into your `$HOME`  
- NixOS `configuration.nix` linked into `/etc/nixos`  
- Scripts listed in `config.json` symlinked into `~/.local/bin`

### Notes on Overriding Files:
- Existing symlinks or files in `$HOME` or `/etc/nixos` will be **overwritten** with the dotfiles versions if they already exist.
- The script **backs up** existing files before making changes, storing them in `~/dotfiles/stow-backups/<timestamp>/`.
- If you don’t want a file to be overwritten, you can either:
  1. Remove the `--restow` option in the script.
  2. Manually move the file before running `setup.sh`.

---

## ⚙️ Configuration

### `config.json`

List any scripts you want exposed on your `PATH`. Paths are **relative** to the repo root:

```json
{
  "add-to-path": [
    "scripts/.scripts/nixos/rebuild",
    "scripts/.scripts/nixos/update"
  ]
}
```

Whenever you add a new helper, just add its repo path here and re-run `./setup.sh`.

---

### `shell.nix`

Provides a throwaway environment with:

- `stow`  (for symlink management)  
- `jq`    (for parsing `config.json`)  

No need to install anything globally—just `nix-shell`.

---

## 📝 License

This project is licensed under the **GNU General Public License (GPL)**. You can view the full license at [project root/LICENSE](LICENSE).

---

## 🔍 Verification

After running `./setup.sh`, verify:

```bash
# Home-files
ls -l ~/.bashrc
ls -l ~/.config/nixos/debbie.nix

# System config
ls -l /etc/nixos/configuration.nix

# Scripts on your PATH
which rebuild update
```

Each should point back into your `~/dotfiles` repo.

