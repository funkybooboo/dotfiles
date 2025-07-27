# 🗂️ Dotfiles

This repo manages:

* 🧩 **Home-directory dotfiles** via GNU Stow
* ⚙️ **NixOS system configuration** (`configuration.nix`)
* 📦 **Utility scripts** (`update`, `sync-docs`, `auto-update`, `clean`, etc.) made available in `~/.local/bin`

---

## 🚀 Quick Start (Fresh NixOS)

These steps assume you’ve already installed NixOS, partitioned/bootstrapped, and added your SSH key to GitHub.

1. **Clone your dotfiles**

   ```bash
   git clone git@github.com:funkybooboo/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Enter the Nix shell**

   ```bash
   nix-shell
   ```

   This gives you `git`, `jq`, without installing them globally.

3. **Create your 2FA secrets**

   ```ini
   # ~/.2fa_secrets
   proton=<YOUR_PROTON_TOTP_SECRET>
   ```

   ```bash
   chmod 600 ~/.2fa_secrets
   ```

4. **Create your tokens file**

   ```ini
   # ~/.tokens
   GH_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXX
   GITLAB_TOKEN=glpat-XXXXXXXXXXXXXXXXXXXXXXXXXXXX
   ```

   ```bash
   chmod 600 ~/.tokens
   ```

5. **Install your NixOS configuration**

   ```bash
   sudo mkdir -p /etc/nixos
   sudo cp etc/nixos/configuration.nix /etc/nixos/configuration.nix
   ```

6. **Bootstrap your dotfiles**

   ```bash
   chmod +x setup.sh
   ./setup.sh --dry-run   # preview which files will be backed up & symlinked
   ./setup.sh             # apply the changes
   ```

7. **Rebuild NixOS**

   ```bash
   sudo nixos-rebuild switch
   ```

8. **Configure Rclone & sync Documents**

   ```bash
   rclone config
   sync-docs
   ```

9. **Run initial system update**

    ```bash
    update
    ```

10. **Reboot to apply all changes**

  ```bash
  sudo reboot
  ```

11. **Backup/Download Important Keys**

    Make sure you securely download and store the following keys:

    - **PGP Key** – for encrypted communications and code signing
    - **Recovery Keys** – for disk encryption, 2FA, or account recovery

---

## 📁 Repository Layout

```
.
├── bash/                      # ~/.bashrc, etc.
├── config/                    # ~/.config/*
├── etc/nixos/                 # NixOS system configuration
│   └── configuration.nix
├── scripts/.scripts/nixos/    # Utility scripts (update, auto-update, clean, sync-docs, rebuild)
├── setup.sh                   # Stow-based bootstrap script
├── shell.nix                  # nix-shell definition
└── config.json                # Lists scripts to symlink into ~/.local/bin
```

---

## ⚙️ Configuration Details

### `config.json`

Defines which scripts get linked into your `~/.local/bin`:

```json
{
  "add-to-path": [
    "scripts/.scripts/nixos/rebuild",
    "scripts/.scripts/nixos/update",
    "scripts/.scripts/nixos/sync-docs",
    "scripts/.scripts/nixos/auto-update",
    "scripts/.scripts/nixos/clean"
  ]
}
```

Whenever you add a new helper under `scripts/.scripts/nixos/`, update this file and re-run:

```bash
./setup.sh
```
