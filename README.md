# 🗂️ **Dotfiles**

This repository manages your **personal dotfiles**, **NixOS system configuration**, and **utility scripts** using [GNU Stow].

It helps you:

* 🧩 **Organize** home-directory dotfiles into modular Stow packages
* 🛠️ **Deploy** your NixOS system config (`configuration.nix`) into `/etc/nixos`
* 📦 **Back up** conflicting files before replacing them with symlinks
* ⚙️ **Register** personal scripts (`rebuild`, `update`, `syncDocuments`) into `~/.local/bin`

---

## 🚀 **Quick Start** (For a Brand-New NixOS Setup)

> These steps assume a fresh NixOS install where partitioning & formatting is already done, and your SSH key is set up in GitHub for cloning repositories.

---


### 🔧 **Setup**

#### 1. **Launch the Nix Shell Environment**

```bash
nix-shell
```

> Installs `git`, `jq`, and other setup tools **without** polluting the global system.

#### 2. **Create Your 2FA Secrets File**

Create a file named `~/.2fa_secrets` to store your TOTP secrets:

```ini
proton=<the TOTP secret for proton>
```

This file will be used by automation scripts like `syncDocuments`.

#### 3. **Clone Your Dotfiles Repository**

```bash
git clone git@github.com:funkybooboo/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

#### 4. **Install System Configuration**

```bash
sudo mkdir -p /etc/nixos
sudo cp etc/nixos/configuration.nix /etc/nixos/configuration.nix
```

> 🔁 Modify if you're using overlays or multiple config files.

#### 5. **Make `setup.sh` Executable**

```bash
chmod +x setup.sh
```

#### 7. **Preview Dotfile Actions (Dry-Run)**

```bash
./setup.sh --dry-run
```

* Shows what files would be symlinked
* Lists what would be backed up to `stow-backups/`

#### 8. **Apply the Dotfiles Setup**

```bash
./setup.sh
```

#### 9. **Rebuild NixOS System**

```bash
sudo nixos-rebuild switch
```

#### 10. **Setup rclone to populate the documents folder**

```bash
rclone config
syncDocuments
```

#### 11. **Update and reboot**

Follow the prompts 

```bash
update
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
