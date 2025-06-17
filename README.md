# 🗂️ Dotfiles

This repository manages your personal dotfiles, NixOS system configuration, and utility scripts using \[GNU Stow]. It:

* **Organizes** your home-directory dotfiles into clean, modular Stow packages
* **Deploys** your NixOS system config (`configuration.nix`) into `/etc/nixos` manually
* **Backs up** conflicting files before replacing them with symlinks
* **Registers** your personal scripts (e.g. `rebuild`, `update`, `syncDocuments`) into `~/.local/bin`

---

## 🚀 Quick Start (Brand-New NixOS Setup)

These steps assume a fresh NixOS installation (disk partitioning and formatting already completed).

### 1. Enable `git` and an editor (`vim`, `nano`, etc.)

1. Edit your NixOS system config:

   ```bash
   sudo nano /etc/nixos/configuration.nix
   ```

2. Add essential packages:

   ```nix
   environment.systemPackages = with pkgs; [
     git
     vim  # optional—use your preferred editor
     # ...add more here
   ];
   ```

3. Rebuild your system:

   ```bash
   sudo nixos-rebuild switch
   ```

---

### 2. Create your 2FA secrets file

Create a file named `~/.2fa_secrets` with your TOTP secrets.

**Example:**

```ini
# ~/.2fa_secrets
proton="<the TOTP secret for proton>"
```

This file is used by automation scripts (e.g. `syncDocuments`).

---

### 3. Clone the dotfiles repo

```bash
git clone https://your.git.repo/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

---

### 4. Install NixOS configuration manually

```bash
sudo mkdir -p /etc/nixos
sudo cp etc/nixos/configuration.nix /etc/nixos/configuration.nix
```

> If you're using overlays or a custom config file, adjust this step.

---

### 5. Make the setup script executable

```bash
chmod +x setup.sh
```

---

### 6. Preview actions (dry-run mode)

```bash
./setup.sh --dry-run
```

This shows which files *would* be linked and which backups would be created.

---

### 7. Apply the dotfiles setup

```bash
./setup.sh
```

* Prompts once for `sudo`
* Conflicting files are backed up into `stow-backups/<timestamp>/`
* Dotfiles are symlinked into `$HOME`
* Scripts listed in `config.json` are symlinked into `~/.local/bin`

---

### 8. Set up Proton Drive sync (optional)

1. Launch rclone configuration:

   ```bash
   rclone config
   ```

2. Create a new remote named `proton`, follow the prompts.

3. Verify the remote:

   ```bash
   rclone lsd proton:
   ```

4. Sync your documents:

   ```bash
   update
   ```

---

## 📁 Repository Layout

```
.
├── bash/                   # ~/.bashrc and related shell files
├── config/.config/…        # ~/.config/*
├── etc/nixos/              # System configuration templates
│   └── configuration.nix
├── gdbinit/                # ~/.gdbinit
├── ideavim/                # ~/.ideavimrc
├── scripts/.scripts/…      # Custom utility scripts
├── vim/                    # ~/.vimrc
├── config.json             # List of helper scripts to add to PATH
├── shell.nix               # nix-shell environment for setup
└── setup.sh                # Main bootstrap script
```

---

## ⚙️ Configuration Details

### `config.json`

Defines which scripts to expose in `~/.local/bin`. Paths are **relative to repo root**:

```json
{
  "add-to-path": [
    "scripts/.scripts/nixos/rebuild",
    "scripts/.scripts/nixos/update",
    "scripts/.scripts/nixos/syncDocuments"
  ]
}
```

To add a new helper, update this file and re-run `./setup.sh`.

---

### `shell.nix`

Provides an isolated shell environment with:

* `stow` – symlink manager
* `jq` – JSON parsing utility

Use with:

```bash
nix-shell
```

No need to install globally.

---

## ✅ Post-Setup Verification

Ensure everything is correctly linked:

```bash
# Home dotfiles
ls -l ~/.bashrc
ls -l ~/.config/nixos/debbie.nix

# System config
ls -l /etc/nixos/configuration.nix

# Scripts on PATH
which rebuild update syncDocuments
```

Each path should resolve to a file inside your `~/dotfiles` repo.
