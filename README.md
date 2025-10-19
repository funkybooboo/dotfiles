# 🗂️ Dotfiles

This repo manages:

* 🧩 **Home-directory dotfiles** — like `.bashrc`, `.gitconfig`, `.config/*`, etc.  
* ⚙️ **System configuration** — optional system setup for NixOS and Ubuntu  
* 🛠️ **Utility scripts** — installed into `~/.local/bin` for convenience  

---

## 🚀 Quick Start (Fresh System)

### 1. Clone your dotfiles

```bash
git clone git@github.com:funkybooboo/dotfiles.git ~/dotfiles
cd ~/dotfiles
````

---

### 2. (Optional) Enter the Nix shell

If you use Nix:

```bash
nix-shell
```

This provides `git`, `jq`, and other tools without installing them globally.

---

### 3. Bootstrap your dotfiles

Preview what will be linked:

```bash
./setup.sh --dry-run
```

Then apply for real:

```bash
./setup.sh
```

What this does:

* Symlinks everything from `home/.local/bin/*` → `~/.local/bin/*`
* Symlinks each folder under `home/.config/*` → `~/.config/*`
* Symlinks all remaining dotfiles in `home/` → `$HOME`
  (excluding `.config` and `.local`)
* Aborts if any destination already exists (safe, no overwrites)

---

### 4. System configuration (optional)

#### 🧊 NixOS

```bash
sudo mkdir -p /etc/nixos
sudo cp root/etc/nixos/configuration.nix /etc/nixos/configuration.nix
sudo nixos-rebuild switch
```

#### 🐧 Ubuntu / Rhino Linux

```bash
update
./install-software/pre-reboot.sh
# The scripts will prompt you to reboot
./install-software/post-reboot.sh
update
```

---

### 5. Rclone & sync

```bash
rclone config
sync-docs
sync-music
sync-audiobooks
```

---

### 6. When you add new files or scripts

After adding new configs or scripts under `home/`, re-run:

```bash
./setup.sh
```

to link them into place.

---

🧹 **Notes**

* Safe by default: the setup script aborts on conflicts (no accidental overwrites).
* Use `--dry-run` to preview actions.
* Designed to work seamlessly on both NixOS and Ubuntu.
