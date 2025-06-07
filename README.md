````markdown
# dotfiles

This repository manages your personal dotfiles, NixOS system configuration, and utility scripts using [GNU Stow]. It:

- **Keeps** your home-directory dotfiles neatly organized into Stow packages  
- **Deploys** your NixOS `configuration.nix` into `/etc/nixos` (manually, see below)  
- **Backs up** any conflicting files before linking  
- **Registers** custom scripts (e.g. `rebuild`, `update`, `syncDocuments`) into `~/.local/bin`

---

## 🚀 Quick Start (Brand-New Machine)

These steps assume a fresh NixOS install and that you’ve already partitioned, formatted, etc.

### 1. Enable `git` (and optionally `vim`) in your system

1. Open your NixOS configuration:

   ```bash
   sudo nano /etc/nixos/configuration.nix
````

2. Locate the `environment.systemPackages` list (create it if missing) and add:

   ```nix
   environment.systemPackages = with pkgs; [
     git
     vim      # optional—remove if you prefer another editor
     # …any other packages you want
   ];
   ```

3. Rebuild & switch:

   ```bash
   sudo nixos-rebuild switch
   ```

### 2. Clone this repo

```bash
git clone https://your.git.repo/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. Install your NixOS configuration

Before running the setup script, copy the provided NixOS config into place:

```bash
sudo mkdir -p /etc/nixos
sudo cp etc/nixos/configuration.nix /etc/nixos/configuration.nix
```

*(If you have custom overlays or use a different filename, adjust accordingly.)*

### 4. Make the setup script executable

```bash
chmod +x setup.sh
```

### 5. Preview changes (dry-run)

```bash
./setup.sh --dry-run
```

You should see “DRY RUN:” messages showing which symlinks and backups *would* be created.

### 6. Apply for real

```bash
./setup.sh
```

* **One sudo prompt** upfront
* Conflicting files moved to `~/dotfiles/stow-backups/<timestamp>/…`
* Home dotfiles linked into your `$HOME`
* Scripts listed in `config.json` symlinked into `~/.local/bin`

### 7. Set up Proton Drive sync

1. Run the interactive `rclone` config:

   ```bash
   rclone config
   ```

2. Create a new remote, name it `proton`, and follow the prompts.

3. Verify you can list your drive:

   ```bash
   rclone lsd proton:
   ```

4. Run the sync script:

   ```bash
   update
   ```

   *(This invokes `syncDocuments` as defined in `config.json`.)*

---

## 📦 Repository Layout

```
.
├── bash/                   # ~/.bashrc
├── config/.config/…        # ~/.config/*
├── etc/nixos/              # NixOS config templates
│   └── configuration.nix
├── gdbinit/                # ~/.gdbinit
├── ideavim/                # ~/.ideavimrc
├── scripts/.scripts/…      # utility scripts
├── vim/                    # ~/.vimrc
├── config.json             # scripts to add to PATH
├── shell.nix               # nix-shell environment (stow, jq)
└── setup.sh                # orchestrates backups, stow, script registration
```

---

## ⚙️ Configuration

### `config.json`

List any scripts you want exposed on your `PATH`. Paths are **relative** to repo root:

```json
{
  "add-to-path": [
    "scripts/.scripts/nixos/rebuild",
    "scripts/.scripts/nixos/update",
    "scripts/.scripts/nixos/syncDocuments"
  ]
}
```

After adding a new helper, re-run `./setup.sh`.

### `shell.nix`

Provides a throwaway environment with:

* `stow`  (for symlink management)
* `jq`    (for parsing `config.json`)

No global installs needed—just `nix-shell`.

---

## 🔍 Verification

After running `./setup.sh`, confirm:

```bash
# Home dotfiles
ls -l ~/.bashrc
ls -l ~/.config/nixos/debbie.nix

# System config (manual copy)
ls -l /etc/nixos/configuration.nix

# Scripts on your PATH
which rebuild update syncDocuments
```

Each should point back into your `~/dotfiles` repo.

