# System Configuration Audit - Implementation Checklist

**Audit found 77+ configuration files** not currently managed in dotfiles.
Working through this checklist will add them in priority order.

---

## 📋 Phase 1: User Configurations (LOW RISK - Start Here)

### Setup - Create Directories
- [ ] `mkdir -p ~/dotfiles/home/.ssh`
- [ ] `mkdir -p ~/dotfiles/home/.gnupg`

### Copy Files to Dotfiles Repo
- [ ] `cp ~/.ssh/config ~/dotfiles/home/.ssh/config`
- [ ] `cp ~/.gnupg/gpg.conf ~/dotfiles/home/.gnupg/`
- [ ] `cp ~/.gnupg/gpg-agent.conf ~/dotfiles/home/.gnupg/`
- [ ] `cp ~/.gnupg/common.conf ~/dotfiles/home/.gnupg/`
- [ ] `cp ~/.bash_logout ~/dotfiles/home/.bash_logout`
- [ ] `cp ~/.config/gtk-3.0/bookmarks ~/dotfiles/home/.config/gtk-3.0/bookmarks`

### Set Permissions
- [ ] `chmod 600 ~/dotfiles/home/.ssh/config`
- [ ] `chmod 600 ~/dotfiles/home/.gnupg/*.conf`

### Update .gitignore
- [ ] Add SSH exclusions to `~/dotfiles/.gitignore`:
  ```gitignore
  # SSH - only track config, never keys
  home/.ssh/*
  !home/.ssh/config
  ```
- [ ] Add GPG exclusions to `~/dotfiles/.gitignore`:
  ```gitignore
  # GPG - only track config files, never keys/keyrings
  home/.gnupg/*
  !home/.gnupg/gpg.conf
  !home/.gnupg/gpg-agent.conf
  !home/.gnupg/common.conf
  ```

### Update setup.sh
- [ ] Add permission handling code after line 149 in `~/dotfiles/setup.sh`:
  ```bash
  # Ensure .ssh and .gnupg directories have correct permissions
  if [[ -d "$HOME/.ssh" ]]; then
    run_cmd chmod 700 "$HOME/.ssh"
  fi
  if [[ -d "$HOME/.gnupg" ]]; then
    run_cmd chmod 700 "$HOME/.gnupg"
  fi
  ```

### Test Phase 1
- [ ] Run `cd ~/dotfiles && ./setup.sh --dry-run`
- [ ] Run `./setup.sh --backup`
- [ ] Verify symlinks: `ls -la ~/.ssh ~/.gnupg`
- [ ] Check permissions: `stat -c "%a %n" ~/.ssh/config ~/.gnupg/gpg.conf`
- [ ] Test SSH: `ssh -T git@github.com`
- [ ] Test GPG: `gpg --list-keys`

### Commit Phase 1
- [ ] `cd ~/dotfiles && git add .`
- [ ] Commit with message:
  ```
  Add SSH, GPG, and shell user configurations

  - Add ~/.ssh/config (keys excluded via .gitignore)
  - Add GPG configs: gpg.conf, gpg-agent.conf, common.conf
  - Add .bash_logout for shell cleanup
  - Add GTK bookmarks for file manager
  - Update setup.sh to ensure proper directory permissions (700 for .ssh/.gnupg)
  - Update .gitignore to prevent tracking private keys
  ```
- [ ] `git push`

---

## 📦 Phase 2.1: Package Management (LOW RISK)

### Setup - Create Directories
- [ ] `mkdir -p ~/dotfiles/root/etc/makepkg.conf.d`

### Copy Files
- [ ] `sudo cp /etc/pacman.conf ~/dotfiles/root/etc/`
- [ ] `sudo cp /etc/makepkg.conf ~/dotfiles/root/etc/`
- [ ] `sudo cp /etc/makepkg.conf.d/fortran.conf ~/dotfiles/root/etc/makepkg.conf.d/`
- [ ] `sudo cp /etc/makepkg.conf.d/rust.conf ~/dotfiles/root/etc/makepkg.conf.d/`
- [ ] `sudo chown -R nate:nate ~/dotfiles/root/etc/`

### Update setup.sh - Add Package Management Deployment
- [ ] Add package management deployment code to `~/dotfiles/setup.sh` after line 342
  <details>
  <summary>Click to see code to add</summary>

  ```bash
  echo ">>> Deploying package management configuration..."

  if [[ -d "$DOTFILES_ROOT_ETC" ]]; then
    PKG_MGMT_FILES=(
      "pacman.conf"
      "makepkg.conf"
      "makepkg.conf.d/fortran.conf"
      "makepkg.conf.d/rust.conf"
    )

    for f in "${PKG_MGMT_FILES[@]}"; do
      src="$DOTFILES_ROOT_ETC/$f"
      if [[ ! -f "$src" ]]; then continue; fi

      dest="/etc/$f"
      dest_dir=$(dirname "$dest")

      if [[ ! -d "$dest_dir" ]]; then
        run_cmd sudo mkdir -p "$dest_dir"
      fi

      if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
        continue
      fi

      if [[ -f "$dest" ]]; then
        if [[ $BACKUP -eq 1 ]]; then
          backup_dest="${dest}.bak.$(date +%s)"
          echo "Backing up $dest → $backup_dest"
          run_cmd sudo cp "$dest" "$backup_dest"
        elif [[ $FORCE -eq 1 ]]; then
          echo "Removing existing $dest"
          run_cmd sudo rm -f "$dest"
        else
          echo "conflict: '$dest' already exists. Use --backup or --force."
          exit 1
        fi
      fi

      run_cmd sudo cp "$src" "$dest"
      run_cmd sudo chown root:root "$dest"
      run_cmd sudo chmod 644 "$dest"
    done

    echo ">>> Package management configuration deployed."
  fi
  ```
  </details>

### Test & Commit
- [ ] Test: `cd ~/dotfiles && ./setup.sh --dry-run`
- [ ] Deploy: `./setup.sh --backup`
- [ ] `git add . && git commit -m "Add pacman and makepkg configuration"`
- [ ] `git push`

---

## 🌐 Phase 2.2: Locale & Console (LOW RISK)

### Setup - Create Directories
- [ ] `mkdir -p ~/dotfiles/root/etc/X11/xorg.conf.d`

### Copy Files
- [ ] `sudo cp /etc/locale.conf ~/dotfiles/root/etc/`
- [ ] `sudo cp /etc/vconsole.conf ~/dotfiles/root/etc/`
- [ ] `sudo cp /etc/X11/xorg.conf.d/00-keyboard.conf ~/dotfiles/root/etc/X11/xorg.conf.d/`
- [ ] `sudo chown -R nate:nate ~/dotfiles/root/etc/`

### Update setup.sh - Add Locale Deployment
- [ ] Add locale/console deployment code to `~/dotfiles/setup.sh` after package management section
  <details>
  <summary>Click to see code to add</summary>

  ```bash
  echo ">>> Deploying locale and console configuration..."

  if [[ -d "$DOTFILES_ROOT_ETC" ]]; then
    LOCALE_CONSOLE_FILES=(
      "locale.conf"
      "vconsole.conf"
      "X11/xorg.conf.d/00-keyboard.conf"
    )

    for f in "${LOCALE_CONSOLE_FILES[@]}"; do
      src="$DOTFILES_ROOT_ETC/$f"
      if [[ ! -f "$src" ]]; then continue; fi

      dest="/etc/$f"
      dest_dir=$(dirname "$dest")

      if [[ ! -d "$dest_dir" ]]; then
        run_cmd sudo mkdir -p "$dest_dir"
      fi

      if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
        continue
      fi

      if [[ -f "$dest" ]]; then
        if [[ $BACKUP -eq 1 ]]; then
          backup_dest="${dest}.bak.$(date +%s)"
          echo "Backing up $dest → $backup_dest"
          run_cmd sudo cp "$dest" "$backup_dest"
        elif [[ $FORCE -eq 1 ]]; then
          echo "Removing existing $dest"
          run_cmd sudo rm -f "$dest"
        else
          echo "conflict: '$dest' already exists. Use --backup or --force."
          exit 1
        fi
      fi

      run_cmd sudo cp "$src" "$dest"
      run_cmd sudo chown root:root "$dest"
      run_cmd sudo chmod 644 "$dest"
    done

    echo ">>> Locale and console configuration deployed."
  fi
  ```
  </details>

### Test & Commit
- [ ] Test: `cd ~/dotfiles && ./setup.sh --dry-run`
- [ ] Deploy: `./setup.sh --backup`
- [ ] `git add . && git commit -m "Add locale, vconsole, and X11 keyboard configuration"`
- [ ] `git push`

---

## 🔐 Phase 2.3: SSH System Configuration (MODERATE RISK)

### Setup - Create Directories
- [ ] `mkdir -p ~/dotfiles/root/etc/ssh/{ssh_config.d,sshd_config.d}`

### Copy Files
- [ ] `sudo cp /etc/ssh/sshd_config ~/dotfiles/root/etc/ssh/`
- [ ] `sudo cp /etc/ssh/ssh_config ~/dotfiles/root/etc/ssh/`
- [ ] `sudo cp /etc/ssh/sshd_config.d/99-archlinux.conf ~/dotfiles/root/etc/ssh/sshd_config.d/`
- [ ] `sudo cp /etc/ssh/ssh_config.d/30-libvirt-ssh-proxy.conf ~/dotfiles/root/etc/ssh/ssh_config.d/`
- [ ] `sudo chown -R nate:nate ~/dotfiles/root/etc/ssh/`

### Update setup.sh - Add SSH Deployment
- [ ] Add SSH deployment code to `~/dotfiles/setup.sh`
  <details>
  <summary>Click to see code to add</summary>

  ```bash
  echo ">>> Deploying SSH configuration..."

  if [[ -d "$DOTFILES_ROOT_ETC/ssh" ]]; then
    SSH_FILES=(
      "ssh/sshd_config"
      "ssh/ssh_config"
      "ssh/sshd_config.d/99-archlinux.conf"
      "ssh/ssh_config.d/30-libvirt-ssh-proxy.conf"
    )

    for f in "${SSH_FILES[@]}"; do
      src="$DOTFILES_ROOT_ETC/$f"
      if [[ ! -f "$src" ]]; then continue; fi

      dest="/etc/$f"
      dest_dir=$(dirname "$dest")

      if [[ ! -d "$dest_dir" ]]; then
        run_cmd sudo mkdir -p "$dest_dir"
      fi

      if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
        continue
      fi

      if [[ -f "$dest" ]]; then
        if [[ $BACKUP -eq 1 ]]; then
          backup_dest="${dest}.bak.$(date +%s)"
          echo "Backing up $dest → $backup_dest"
          run_cmd sudo cp "$dest" "$backup_dest"
        elif [[ $FORCE -eq 1 ]]; then
          echo "Removing existing $dest"
          run_cmd sudo rm -f "$dest"
        else
          echo "conflict: '$dest' already exists. Use --backup or --force."
          exit 1
        fi
      fi

      run_cmd sudo cp "$src" "$dest"
      run_cmd sudo chown root:root "$dest"
      run_cmd sudo chmod 644 "$dest"
    done

    # Test SSH daemon config before restarting
    if [[ $DRY_RUN -eq 0 ]]; then
      echo "Testing SSH daemon configuration..."
      if sudo sshd -t; then
        echo "SSH config valid, restarting daemon..."
        run_cmd sudo systemctl restart sshd
      else
        echo "ERROR: SSH config test failed! Not restarting daemon."
        exit 1
      fi
    fi

    echo ">>> SSH configuration deployed."
  fi
  ```
  </details>

### Test & Commit
- [ ] Test: `cd ~/dotfiles && ./setup.sh --dry-run`
- [ ] **IMPORTANT:** Test SSH config: `sudo sshd -t`
- [ ] Keep current session open!
- [ ] Deploy: `./setup.sh --backup`
- [ ] Verify SSH still works
- [ ] `git add . && git commit -m "Add SSH client and server system configuration"`
- [ ] `git push`

---

## ⚙️ Phase 2.4: Systemd Core Configuration (MODERATE RISK)

### Setup - Create Directories
- [ ] `mkdir -p ~/dotfiles/root/etc/systemd/system.conf.d`
- [ ] `mkdir -p ~/dotfiles/root/etc/systemd/resolved.conf.d`
- [ ] `mkdir -p ~/dotfiles/root/etc/systemd/system/docker.service.d`
- [ ] `mkdir -p ~/dotfiles/root/etc/systemd/network`

### Copy Core Config Files
- [ ] `sudo cp /etc/systemd/logind.conf ~/dotfiles/root/etc/systemd/`
- [ ] `sudo cp /etc/systemd/journald.conf ~/dotfiles/root/etc/systemd/`
- [ ] `sudo cp /etc/systemd/resolved.conf ~/dotfiles/root/etc/systemd/`
- [ ] `sudo cp /etc/systemd/timesyncd.conf ~/dotfiles/root/etc/systemd/`
- [ ] `sudo cp /etc/systemd/networkd.conf ~/dotfiles/root/etc/systemd/`
- [ ] `sudo cp /etc/systemd/sleep.conf ~/dotfiles/root/etc/systemd/`
- [ ] `sudo cp /etc/systemd/user.conf ~/dotfiles/root/etc/systemd/`

### Copy Drop-in Configs
- [ ] `sudo cp /etc/systemd/system.conf.d/10-faster-shutdown.conf ~/dotfiles/root/etc/systemd/system.conf.d/`
- [ ] `sudo cp /etc/systemd/resolved.conf.d/*.conf ~/dotfiles/root/etc/systemd/resolved.conf.d/`
- [ ] `sudo cp /etc/systemd/system/docker.service.d/no-block-boot.conf ~/dotfiles/root/etc/systemd/system/docker.service.d/`
- [ ] `sudo cp /etc/systemd/network/*.network* ~/dotfiles/root/etc/systemd/network/`
- [ ] `sudo chown -R nate:nate ~/dotfiles/root/etc/systemd/`

### Update setup.sh - Add Systemd Deployment
- [ ] Add systemd deployment code to `~/dotfiles/setup.sh`
  <details>
  <summary>Click to see code to add</summary>

  ```bash
  echo ">>> Deploying systemd configuration..."

  if [[ -d "$DOTFILES_ROOT_ETC/systemd" ]]; then
    SYSTEMD_FILES=(
      "systemd/logind.conf"
      "systemd/journald.conf"
      "systemd/resolved.conf"
      "systemd/timesyncd.conf"
      "systemd/networkd.conf"
      "systemd/sleep.conf"
      "systemd/user.conf"
      "systemd/system.conf.d/10-faster-shutdown.conf"
      "systemd/resolved.conf.d/10-disable-multicast.conf"
      "systemd/resolved.conf.d/20-docker-dns.conf"
      "systemd/resolved.conf.d/no-llmnr.conf"
      "systemd/system/docker.service.d/no-block-boot.conf"
      "systemd/network/20-ethernet.network"
      "systemd/network/20-wlan.network.disabled"
      "systemd/network/20-wwan.network"
    )

    for f in "${SYSTEMD_FILES[@]}"; do
      src="$DOTFILES_ROOT_ETC/$f"
      if [[ ! -f "$src" ]]; then continue; fi

      dest="/etc/$f"
      dest_dir=$(dirname "$dest")

      if [[ ! -d "$dest_dir" ]]; then
        run_cmd sudo mkdir -p "$dest_dir"
      fi

      if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
        continue
      fi

      if [[ -f "$dest" ]]; then
        if [[ $BACKUP -eq 1 ]]; then
          backup_dest="${dest}.bak.$(date +%s)"
          echo "Backing up $dest → $backup_dest"
          run_cmd sudo cp "$dest" "$backup_dest"
        elif [[ $FORCE -eq 1 ]]; then
          echo "Removing existing $dest"
          run_cmd sudo rm -f "$dest"
        else
          echo "conflict: '$dest' already exists. Use --backup or --force."
          exit 1
        fi
      fi

      run_cmd sudo cp "$src" "$dest"
      run_cmd sudo chown root:root "$dest"
      run_cmd sudo chmod 644 "$dest"
    done

    # Reload systemd after configuration changes
    if [[ $DRY_RUN -eq 0 ]]; then
      echo "Reloading systemd daemon..."
      run_cmd sudo systemctl daemon-reload
    fi

    echo ">>> Systemd configuration deployed."
    echo "NOTE: Some changes may require a reboot to take full effect."
  fi
  ```
  </details>

### Test & Commit
- [ ] Test: `cd ~/dotfiles && ./setup.sh --dry-run`
- [ ] Deploy: `./setup.sh --backup`
- [ ] Check for failures: `systemctl --failed`
- [ ] Check logs: `journalctl -xe`
- [ ] `git add . && git commit -m "Add systemd core and service configurations"`
- [ ] `git push`

---

## 🚀 Phase 2.5: Boot & Kernel Configuration (HIGH RISK - OPTIONAL)

⚠️ **WARNING:** This phase affects boot process. Only proceed if:
- [ ] You have a bootable USB recovery drive ready
- [ ] OR you can test in a VM first
- [ ] You understand the risks

### Setup - Create Directories
- [ ] `mkdir -p ~/dotfiles/root/boot`
- [ ] `mkdir -p ~/dotfiles/root/etc/mkinitcpio.conf.d`

### Copy Files
- [ ] `sudo cp /boot/limine.conf ~/dotfiles/root/boot/`
- [ ] `sudo cp /etc/mkinitcpio.conf ~/dotfiles/root/etc/`
- [ ] `sudo cp /etc/mkinitcpio.conf.d/omarchy_hooks.conf ~/dotfiles/root/etc/mkinitcpio.conf.d/`
- [ ] `sudo cp /etc/mkinitcpio.conf.d/thunderbolt_module.conf ~/dotfiles/root/etc/mkinitcpio.conf.d/`
- [ ] `sudo chown -R nate:nate ~/dotfiles/root/`

### Update setup.sh - Add Boot Deployment
- [ ] Add boot configuration deployment code to `~/dotfiles/setup.sh`
  <details>
  <summary>Click to see code to add</summary>

  ```bash
  echo ">>> Deploying boot and kernel configuration..."

  if [[ -d "$HOME/dotfiles/root/boot" ]]; then
    BOOT_KERNEL_FILES=(
      "boot/limine.conf"
      "etc/mkinitcpio.conf"
      "etc/mkinitcpio.conf.d/omarchy_hooks.conf"
      "etc/mkinitcpio.conf.d/thunderbolt_module.conf"
    )

    for f in "${BOOT_KERNEL_FILES[@]}"; do
      src="$HOME/dotfiles/root/$f"
      if [[ ! -f "$src" ]]; then continue; fi

      dest="/$f"
      dest_dir=$(dirname "$dest")

      if [[ ! -d "$dest_dir" ]]; then
        run_cmd sudo mkdir -p "$dest_dir"
      fi

      if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
        continue
      fi

      if [[ -f "$dest" ]]; then
        if [[ $BACKUP -eq 1 ]]; then
          backup_dest="${dest}.bak.$(date +%s)"
          echo "Backing up $dest → $backup_dest"
          run_cmd sudo cp "$dest" "$backup_dest"
        elif [[ $FORCE -eq 1 ]]; then
          echo "Removing existing $dest"
          run_cmd sudo rm -f "$dest"
        else
          echo "conflict: '$dest' already exists. Use --backup or --force."
          exit 1
        fi
      fi

      run_cmd sudo cp "$src" "$dest"
      run_cmd sudo chown root:root "$dest"
      run_cmd sudo chmod 644 "$dest"
    done

    echo ">>> Boot and kernel configuration deployed."
    echo "WARNING: Changes to mkinitcpio.conf require running: sudo mkinitcpio -P"
    echo "WARNING: Changes to limine.conf are active immediately on next boot."
  fi
  ```
  </details>

### Test & Commit
- [ ] Test: `cd ~/dotfiles && ./setup.sh --dry-run`
- [ ] Deploy: `./setup.sh --backup`
- [ ] If mkinitcpio.conf changed: `sudo mkinitcpio -P`
- [ ] `git add . && git commit -m "Add boot loader and initramfs configuration [TESTED]"`
- [ ] `git push`
- [ ] **Test reboot in safe environment**

---

## 📝 Documentation Updates

### Update README.md
- [ ] Add "System Configurations Managed" section to `~/dotfiles/README.md`:
  ```markdown
  ## System Configurations Managed

  This dotfiles repository manages both user and system-level configurations:

  **User Configs:**
  - SSH client (~/.ssh/config)
  - GPG (gpg.conf, gpg-agent.conf, common.conf)
  - Shell, terminal, editors, development tools

  **System Configs (deployed via sudo):**
  - Package management (pacman, makepkg)
  - Systemd (logind, journald, resolved, timesyncd)
  - SSH server (sshd_config)
  - Boot loader (limine.conf) - optional
  - Kernel initramfs (mkinitcpio.conf) - optional
  - Locale and console settings

  Run `./setup.sh --backup` to deploy all configurations.
  ```

### Commit Documentation
- [ ] `cd ~/dotfiles && git add README.md`
- [ ] `git commit -m "Document system configuration management in README"`
- [ ] `git push`

---

## ✅ Final Checklist

- [ ] Phase 1 completed and tested
- [ ] Phase 2.1 (Package Management) completed
- [ ] Phase 2.2 (Locale) completed
- [ ] Phase 2.3 (SSH) completed
- [ ] Phase 2.4 (Systemd) completed
- [ ] Phase 2.5 (Boot) completed (optional)
- [ ] Documentation updated
- [ ] All changes pushed to remote repository

---

## 🆘 Troubleshooting

**If SSH locks you out:**
- Use `.bak` files: `sudo cp /etc/ssh/sshd_config.bak.TIMESTAMP /etc/ssh/sshd_config`
- Restart: `sudo systemctl restart sshd`

**If systemd services fail:**
- Check: `systemctl --failed`
- Restore: `sudo cp /etc/systemd/FILE.bak.TIMESTAMP /etc/systemd/FILE`
- Reload: `sudo systemctl daemon-reload`

**If system won't boot (Phase 2.5):**
- Boot from USB
- Mount root partition
- Restore: `cp /etc/mkinitcpio.conf.bak.TIMESTAMP /etc/mkinitcpio.conf`
- Regenerate: `mkinitcpio -P`
- Reboot

---

## 📊 Progress Tracker

**Completed:** 0/6 phases
- [ ] Phase 1: User Configurations
- [ ] Phase 2.1: Package Management
- [ ] Phase 2.2: Locale & Console
- [ ] Phase 2.3: SSH System
- [ ] Phase 2.4: Systemd
- [ ] Phase 2.5: Boot & Kernel (optional)
