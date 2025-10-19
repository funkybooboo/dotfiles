# 🗂️ Dotfiles

This repo manages:

* 🧩 **Home-directory dotfiles** (`.bashrc`, `.config/*`, `.scripts/*`, wallpapers, etc.)
* ⚙️ **System configuration** (`configuration.nix` for NixOS, optional for Rhino Linux)
* 📦 **Utility scripts** (update, sync-docs, auto-update, clean, etc.) installed into `~/.local/bin` via `config.json`

---

## 🚀 Quick Start (Fresh System)

1. **Clone your dotfiles**

   ```bash
   git clone git@github.com:funkybooboo/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Enter the Nix shell (optional)**

   ```bash
   nix-shell
   ```

   Provides `git`, `jq`, etc. without global installs.

3. **Bootstrap your dotfiles**

   ```bash
   ./setup.sh --dry-run   # preview symlinks
   ./setup.sh             # apply symlinks
   ```

4. **System configuration**

   ```bash
   # NixOS only
   sudo mkdir -p /etc/nixos
   sudo cp root/etc/nixos/configuration.nix /etc/nixos/configuration.nix
   sudo nixos-rebuild switch
   ```

   ```bash
   # Ubuntu
   update
   ./install-software/pre-reboot.sh
   # The scripts will prompt you to reboot
   ./install-software/post-reboot.sh
   update
   ```

5. **Rclone & sync**

   ```bash
   rclone config
   sync-docs
   sync-music
   sync-audiobooks
   ```

---

## 📁 Repository Layout

```
.
├── home/                       # → $HOME
│   ├── .bashrc
│   ├── .config/                # configs for fish, kitty, hyprland, nvim, waybar, rofi, etc.
│   ├── .scripts/               # scripts (os utils, waybar modules, break-reminder, etc.)
│   ├── Pictures/wallpapers/    # wallpapers
│   ├── .gitconfig
│   ├── .ideavimrc
│   ├── .vimrc
│   └── more…
├── root/                       # → /
│   └── etc/nixos/configuration.nix
├── install-software/           # distro setup scripts
│   └── rhino_linux.sh
├── config.json                 # maps scripts → ~/.local/bin
├── setup.sh                    # symlink/bootstrap script
├── shell.nix                   # nix-shell definition
├── LICENSE
└── README.md
```

---

## ⚙️ Scripts (`config.json`)

`config.json` controls which scripts get linked into `~/.local/bin`. Example:

```json
{
  "add-to-path": [
    "home/.scripts/os/update",
    "home/.scripts/os/sync-docs",
    "home/.scripts/os/auto-update",
    "home/.scripts/os/clean",
    "home/.scripts/os/rebuild"
  ]
}
```

Whenever you add new scripts, update this file and re-run:

```bash
./setup.sh
```
