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

### 🛠️ **Automatic Setup with `install.sh`**

If you'd like to automate the entire process, use the `install.sh` script. This will handle enabling Git, setting up your 2FA secrets, cloning the dotfiles repo, installing the system configuration, applying the dotfiles, and optionally setting up Proton Drive sync.

#### How to Run the Install Script

1. Run the script with the following command:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/funkybooboo/dotfiles/main/install.sh -o install.sh
   chmod +x install.sh
   ./install.sh
   ```

2. The script will:

   * Enable Git in your NixOS system.
   * Prompt for your Proton TOTP secret and store it securely in `~/.2fa_secrets`.
   * Clone the dotfiles repository.
   * Install your NixOS configuration.
   * Make the `setup.sh` script executable and apply the dotfiles setup.
   * Optionally, run a system update (`update` command).
   * Optionally, set up Proton Drive sync using **rclone**.
   * Optionally, reboot the system.

---

### 🔧 **Manual Setup**

#### 1. **Enable Git & Your Preferred Editor**

1. Open your system config:

   ```bash
   sudo nano /etc/nixos/configuration.nix
   ```

2. Add essential packages:

   ```nix
   environment.systemPackages = with pkgs; [
     git
   ];
   ```

3. Rebuild the system:

   ```bash
   sudo nixos-rebuild switch
   ```

#### 2. **Create Your 2FA Secrets File**

Create a file named `~/.2fa_secrets` to store your TOTP secrets:

```ini
proton="<the TOTP secret for proton>"
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

#### 6. **Launch the Nix Shell Environment**

```bash
nix-shell
```

> Installs `stow`, `jq`, and other setup tools **without** polluting the global system.

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
