# 🗂️ **Dotfiles**

This repository manages your **personal dotfiles**, **NixOS system configuration**, and **utility scripts** using \[GNU Stow].

It helps you:

* 🧩 **Organize** home-directory dotfiles into modular Stow packages
* 🛠️ **Deploy** your NixOS system config (`configuration.nix`) into `/etc/nixos`
* 📦 **Back up** conflicting files before replacing them with symlinks
* ⚙️ **Register** personal scripts (`rebuild`, `update`, `syncDocuments`) into `~/.local/bin`

---

## 🚀 **Quick Start** (For a Brand-New NixOS Setup)

> These steps assume a fresh NixOS install where partitioning & formatting is already done.

---

### 🔧 1. Enable Git & Your Preferred Editor

1. Open your system config:

   ```bash
   sudo nano /etc/nixos/configuration.nix
   ```

2. Add essential packages:

   ```nix
   environment.systemPackages = with pkgs; [
     git
     vim
   ];
   ```

3. Rebuild the system:

   ```bash
   sudo nixos-rebuild switch
   ```

---

### 🔐 2. Create Your 2FA Secrets File

Create a file named `~/.2fa_secrets` to store your TOTP secrets:

```ini
proton="<the TOTP secret for proton>"
```

This is used by automation scripts like `syncDocuments`.

---

### 📥 3. Clone Your Dotfiles Repository

```bash
git clone git@github.com:funkybooboo/dotfiles.git
cd ~/dotfiles
```

---

### 🖥️ 4. Install System Configuration

```bash
sudo mkdir -p /etc/nixos
sudo cp etc/nixos/configuration.nix /etc/nixos/configuration.nix
```

> 🔁 Modify if you're using overlays or multiple config files.

---

### ⚙️ 5. Make `setup.sh` Executable

```bash
chmod +x setup.sh
```

---

### 🧪 5a. Launch the Nix Shell Environment

```bash
nix-shell
```

> Installs `stow`, `jq`, and other setup tools **without** polluting the global system.

---

### 🔍 6. Preview Dotfile Actions (Dry-Run)

```bash
./setup.sh --dry-run
```

* Shows what files would be symlinked
* Lists what would be backed up to `stow-backups/`

---

### 🚚 7. Apply the Dotfiles Setup

```bash
./setup.sh
```

* Prompts once for `sudo`
* Backs up conflicting files to `stow-backups/<timestamp>/`
* Symlinks dotfiles to `$HOME`
* Links scripts from `config.json` into `~/.local/bin`

Then:

```bash
sudo nixos-rebuild switchate1
```

---

### ☁️ 8. Set Up Proton Drive Sync (Optional)

1. Start Rclone config:

   ```bash
   rclone config
   ```

2. Add a new remote named `proton`

3. Verify it works:

   ```bash
   rclone lsd proton:
   ```

4. Sync:

   ```bash
   syncDocuments
   ```

---

## 🗂️ Repository Layout

```
.
├── bash/                   # ~/.bashrc and related shell files
├── config/.config/…        # ~/.config/*
├── etc/nixos/              # NixOS system config
│   └── configuration.nix
├── gdbinit/                # ~/.gdbinit
├── ideavim/                # ~/.ideavimrc
├── scripts/.scripts/…      # Utility scripts
├── vim/                    # ~/.vimrc
├── config.json             # Lists scripts to expose in ~/.local/bin
├── shell.nix               # Nix shell env for setup
└── setup.sh                # Main bootstrap script
```

---

## ⚙️ Configuration Details

### `config.json`

Defines helper scripts to symlink into `~/.local/bin`.

```json
{
  "add-to-path": [
    "scripts/.scripts/nixos/rebuild",
    "scripts/.scripts/nixos/update",
    "scripts/.scripts/nixos/syncDocuments"
  ]
}
```

> Add new tools by updating this file and re-running `./setup.sh`.

---

### `shell.nix`

Used for bootstrapping your setup tools in an isolated environment:

* `stow` – symlink manager
* `jq` – JSON parser

Launch it with:

```bash
nix-shell
```

---

## ✅ Post-Setup Checklist

Ensure everything is properly linked and on your PATH:

```bash
# Check symlinked dotfiles
ls -l ~/.bashrc
ls -l ~/.config/nixos/debbie.nix

# Check system config
ls -l /etc/nixos/configuration.nix

# Confirm scripts are accessible
which rebuild update syncDocuments
```

Each path should point into your `~/dotfiles` folder.
