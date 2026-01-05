#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# setup.sh — symlink your dotfiles and local binaries into $HOME
#            but abort on any conflict (no auto-removal)
# -----------------------------------------------------------------------------

DRY_RUN=0
FORCE=0
BACKUP=0

usage() {
  cat <<EOF
Usage: $0 [--dry-run|-n] [--force|-f] [--backup|-b]

  --dry-run, -n   Print the commands that would be run, but do not execute them.
  --force, -f     Remove existing files/symlinks before creating new ones.
  --backup, -b    Backup existing files/symlinks by renaming them with .bak suffix.
  --help, -h      Show this help message.
EOF
  exit 1
}

# parse args
while [[ $# -gt 0 ]]; do
  case $1 in
  -n | --dry-run)
    DRY_RUN=1
    shift
    ;;
  -f | --force)
    FORCE=1
    shift
    ;;
  -b | --backup)
    BACKUP=1
    shift
    ;;
  -h | --help) usage ;;
  *) usage ;;
  esac
done

# helper: run or echo
run_cmd() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "+ $*"
  else
    "$@"
  fi
}

# helper: check if we should create symlink
# If dest is already a symlink pointing to the correct source, skip it (idempotent)
# Returns: 0 (success) if should create symlink, 1 (failure) if should skip
check_should_create() {
  local dest="$1"
  local src="$2"  # Expected source path

  # If dest is already a symlink to the correct source, no need to create (idempotent!)
  if [[ -L "$dest" ]]; then
    local current_target
    current_target=$(readlink "$dest")
    if [[ "$current_target" == "$src" ]]; then
      # Already correctly symlinked, skip creation
      return 1
    fi
  fi

  # Dest exists but is not the correct symlink
  if [[ -e "$dest" ]] || [[ -L "$dest" ]]; then
    if [[ $BACKUP -eq 1 ]]; then
      local backup_dest="${dest}.bak"
      # If .bak already exists, add a number
      local counter=1
      while [[ -e "$backup_dest" ]]; do
        backup_dest="${dest}.bak.${counter}"
        ((counter++))
      done
      echo "Backing up existing: $dest → $backup_dest"
      run_cmd mv "$dest" "$backup_dest"
      return 0  # Conflict resolved, proceed with symlink creation
    elif [[ $FORCE -eq 1 ]]; then
      echo "Removing existing: $dest"
      run_cmd rm -rf "$dest"
      return 0  # Conflict resolved, proceed with symlink creation
    else
      echo "conflict: '$dest' already exists. Use --backup to backup or --force to overwrite."
      exit 1
    fi
  fi

  # No conflict, proceed with symlink creation
  return 0
}

# 1) cd into repo root
cd "$(dirname "${BASH_SOURCE[0]}")"

# 2) link everything from home/.local/bin/* → ~/.local/bin/*
echo ">>> Linking executables into ~/.local/bin"
run_cmd mkdir -p "$HOME/.local/bin"
for entry in home/.local/bin/*; do
  dest="$HOME/.local/bin/$(basename "$entry")"
  src="$PWD/$entry"
  if check_should_create "$dest" "$src"; then
    run_cmd ln -s "$src" "$dest"
  fi
done

# 2b) link everything from home/.local/lib/* → ~/.local/lib/*
if [[ -d "home/.local/lib" ]]; then
  echo ">>> Linking library scripts into ~/.local/lib"
  run_cmd mkdir -p "$HOME/.local/lib"
  for entry in home/.local/lib/*; do
    dest="$HOME/.local/lib/$(basename "$entry")"
    src="$PWD/$entry"
    if check_should_create "$dest" "$src"; then
      run_cmd ln -s "$src" "$dest"
    fi
  done
fi

# 3) link each folder and file under home/.config → ~/.config/*
echo ">>> Linking config folders and files into ~/.config"
run_cmd mkdir -p "$HOME/.config"
for entry in home/.config/*; do
  dest="$HOME/.config/$(basename "$entry")"
  src="$PWD/$entry"
  if check_should_create "$dest" "$src"; then
    run_cmd ln -s "$src" "$dest"
  fi
done

# 4) link per-file dotfiles from home/* → $HOME (excluding .config and .local)
echo ">>> Linking dotfiles into \$HOME"
while IFS= read -r src; do
  rel="${src#"$PWD/home/"}"
  dest="$HOME/$rel"
  if check_should_create "$dest" "$src"; then
    run_cmd mkdir -p "$(dirname "$dest")"
    run_cmd ln -s "$src" "$dest"
  fi
done < <(
  find "$PWD/home" -type f \
    ! -path "$PWD/home/.config/*" \
    ! -path "$PWD/home/.local/*"
)

# 2c) link everything from home/.local/share/* → ~/.local/share/*
if [[ -d "home/.local/share" ]]; then
  echo ">>> Linking shared files into ~/.local/share"
  run_cmd mkdir -p "$HOME/.local/share"

  # Link omarchy and other share items
  for entry in home/.local/share/*; do
    dest="$HOME/.local/share/$(basename "$entry")"
    src="$PWD/$entry"

    # If it's the omarchy directory, handle it specially
    if [[ "$(basename "$entry")" == "omarchy" && -d "$entry" ]]; then
      run_cmd mkdir -p "$HOME/.local/share/omarchy"

      # Link omarchy bin scripts
      if [[ -d "$entry/bin" ]]; then
        run_cmd mkdir -p "$HOME/.local/share/omarchy/bin"
        for script in "$entry/bin"/*; do
          if [[ -f "$script" ]]; then
            script_dest="$HOME/.local/share/omarchy/bin/$(basename "$script")"
            script_src="$PWD/$script"
            if check_should_create "$script_dest" "$script_src"; then
              run_cmd ln -s "$script_src" "$script_dest"
            fi
          fi
        done
      fi

      # Link omarchy hypr configs
      if [[ -d "$entry/hypr" ]]; then
        run_cmd mkdir -p "$HOME/.local/share/omarchy/hypr"
        while IFS= read -r src_file; do
          src_file_abs="$PWD/$src_file"
          rel="${src_file#"$entry/hypr/"}"
          hypr_dest="$HOME/.local/share/omarchy/hypr/$rel"
          if check_should_create "$hypr_dest" "$src_file_abs"; then
            run_cmd mkdir -p "$(dirname "$hypr_dest")"
            run_cmd ln -s "$src_file_abs" "$hypr_dest"
          fi
        done < <(find "$entry/hypr" -type f)
      fi

      # Link omarchy README
      if [[ -f "$entry/README.md" ]]; then
        run_cmd mkdir -p "$HOME/.local/share/omarchy/home"
        readme_dest="$HOME/.local/share/omarchy/home/README.md"
        readme_src="$PWD/$entry/README.md"
        if check_should_create "$readme_dest" "$readme_src"; then
          run_cmd ln -s "$readme_src" "$readme_dest"
        fi
      fi
    else
      # For non-omarchy items, just symlink directly
      if check_should_create "$dest" "$src"; then
        run_cmd ln -s "$src" "$dest"
      fi
    fi
  done
fi

suffix=""
if [[ $DRY_RUN -eq 1 ]]; then
  suffix=" (dry-run)"
fi

# Set up NAS sync
echo ">>> Setting up NAS sync"
run_cmd mkdir -p "$HOME/.config/nas-sync"

PASSWORD_FILE="$HOME/.config/nas-sync/rsync-password"
if [[ ! -f "$PASSWORD_FILE" ]] && [[ $DRY_RUN -eq 0 ]]; then
  echo ""
  echo "NAS rsync password file not found."
  echo "Please enter your NAS rsync password (or press Enter to skip):"
  read -s -r nas_password
  if [[ -n "$nas_password" ]]; then
    echo "$nas_password" > "$PASSWORD_FILE"
    chmod 600 "$PASSWORD_FILE"
    echo "Password file created at $PASSWORD_FILE"
  else
    echo "Skipping password setup. Create it later with:"
    echo "   echo 'your_password' > $PASSWORD_FILE && chmod 600 $PASSWORD_FILE"
  fi
elif [[ -f "$PASSWORD_FILE" ]]; then
  echo "Password file already exists"
fi

# Reload systemd and enable NAS sync timers
if [[ $DRY_RUN -eq 0 ]]; then
  echo ">>> Enabling NAS sync timers"
  systemctl --user daemon-reload

  for sync_type in documents music photos audiobooks; do
    systemctl --user enable "nas-sync-${sync_type}.timer"
    systemctl --user start "nas-sync-${sync_type}.timer"
  done

  echo "NAS sync timers enabled and started"
  echo ""
  echo "Check timer status with: systemctl --user list-timers"
  echo "View sync logs with: journalctl --user -u nas-sync-documents.service -f"
else
  echo "+ systemctl --user daemon-reload"
  echo "+ systemctl --user enable nas-sync-documents.timer"
  echo "+ systemctl --user start nas-sync-documents.timer"
  echo "+ systemctl --user enable nas-sync-music.timer"
  echo "+ systemctl --user start nas-sync-music.timer"
  echo "+ systemctl --user enable nas-sync-photos.timer"
  echo "+ systemctl --user start nas-sync-photos.timer"
  echo "+ systemctl --user enable nas-sync-audiobooks.timer"
  echo "+ systemctl --user start nas-sync-audiobooks.timer"
fi

# Enable battery notification timer
if [[ $DRY_RUN -eq 0 ]]; then
  echo ">>> Enabling battery notification timer"
  systemctl --user enable battery-notify.timer
  systemctl --user start battery-notify.timer
  echo "Battery notification timer enabled and started"
else
  echo "+ systemctl --user enable battery-notify.timer"
  echo "+ systemctl --user start battery-notify.timer"
fi

# Install power profile auto-switching udev rule
echo ">>> Installing power profile auto-switching"
UDEV_RULE_SRC="$PWD/root/etc/udev/rules.d/99-power-profile.rules"
UDEV_RULE_DEST="/etc/udev/rules.d/99-power-profile.rules"

if [[ -f "$UDEV_RULE_SRC" ]]; then
  if [[ $DRY_RUN -eq 0 ]]; then
    if sudo cp "$UDEV_RULE_SRC" "$UDEV_RULE_DEST"; then
      echo "Udev rule installed to $UDEV_RULE_DEST"
      sudo udevadm control --reload-rules
      sudo udevadm trigger --subsystem-match=power_supply
      echo "Power profile auto-switching enabled"
      echo "System will automatically switch to power-saver on battery and performance when plugged in"
    else
      echo "Warning: Failed to install udev rule. Power profile auto-switching not enabled."
      echo "You can install it manually with: sudo cp $UDEV_RULE_SRC $UDEV_RULE_DEST"
    fi
  else
    echo "+ sudo cp $UDEV_RULE_SRC $UDEV_RULE_DEST"
    echo "+ sudo udevadm control --reload-rules"
    echo "+ sudo udevadm trigger --subsystem-match=power_supply"
  fi
else
  echo "Warning: Power profile udev rule not found at $UDEV_RULE_SRC"
fi

echo ">>> Deploying DNS configuration..."

DOTFILES_ROOT_ETC="$HOME/dotfiles/root/etc"
DNS_FILES=(dnsmasq.conf dnsmasq.hosts resolv.conf "NetworkManager/NetworkManager.conf")

for f in "${DNS_FILES[@]}"; do
    src="$DOTFILES_ROOT_ETC/$f"
    dest="/etc/$f"

    # Check if file is already identical (idempotent)
    if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
        # Files are identical, skip
        continue
    fi

    # File exists but is different
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

    # Copy file
    run_cmd sudo cp "$src" "$dest"
    run_cmd sudo chown root:root "$dest"
    run_cmd sudo chmod 644 "$dest"
done

# Restart and enable dnsmasq
run_cmd sudo systemctl restart dnsmasq
run_cmd sudo systemctl enable dnsmasq

echo ">>> DNS configuration deployed."

echo ">>> Done${suffix}."

