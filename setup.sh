#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# setup.sh — symlink dotfiles, enable services, set up VPN/NAS
#
# Order of operations:
#   1. Packages    (--install: run install.sh first)
#   2. Symlinks    (bins, libs, share, config files, dotfiles, /etc files)
#   3. Permissions (.ssh, .gnupg)
#   4. systemd     (daemon-reload, enable user services)
#   5. VPN         (--with-vpn: install WireGuard config)
#   6. NAS sync    (--with-nas-sync: initial clone + enable timers)
# -----------------------------------------------------------------------------

DRY_RUN=0
FORCE=0
BACKUP=0
MERGE=0
WITH_VPN=0
WITH_NAS_SYNC=0
INSTALL=0

usage() {
  cat <<EOF
Usage: $0 [--dry-run|-n] [--force|-f] [--backup|-b] [--merge|-m] [--with-vpn] [--with-nas-sync] [--install|-i]

  --dry-run, -n       Print the commands that would be run, but do not execute them.
  --force, -f         Remove existing files/symlinks before creating new ones.
  --backup, -b        Backup existing files/symlinks by renaming them with .bak suffix.
  --merge, -m         On conflict, open nvim diff to merge existing file into the dotfiles
                      source, then symlink. Saves merged result back into the dotfiles repo.
  --with-vpn          Install WireGuard config to /etc/wireguard/ (optional).
  --with-nas-sync     Enable NAS sync timers setup (optional).
  --install, -i       Run install.sh to install packages before setup (optional).
  --help, -h          Show this help message.
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case $1 in
  -n | --dry-run)    DRY_RUN=1;       shift ;;
  -f | --force)      FORCE=1;         shift ;;
  -b | --backup)     BACKUP=1;        shift ;;
  -m | --merge)      MERGE=1;         shift ;;
  --with-vpn)        WITH_VPN=1;      shift ;;
  --with-nas-sync)   WITH_NAS_SYNC=1; shift ;;
  -i | --install)    INSTALL=1;       shift ;;
  -h | --help)       usage ;;
  *)                 usage ;;
  esac
done

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

run_cmd() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "+ $*"
  else
    "$@"
  fi
}

# Open nvim diff to merge the existing system file (left, read-only) into the
# dotfiles source (right, editable). The merged result stays in the dotfiles
# repo so the subsequent symlink points to the merged content.
#
# If the destination file is root-owned and unreadable by the current user,
# copy it to a temp file first so nvim can open it without sudo.
merge_into_src() {
  local dest="$1"
  local src="$2"

  echo "Merging: $dest  →  $src"
  echo "  Left (read-only): existing system file"
  echo "  Right (edit this): dotfiles source — save & quit when done (:wqa)"

  local left="$dest"
  local tmp_left=""

  # If dest is not readable by current user, copy to a temp file via sudo
  if [[ ! -r "$dest" ]]; then
    tmp_left=$(mktemp)
    sudo cp "$dest" "$tmp_left"
    sudo chmod 644 "$tmp_left"
    left="$tmp_left"
  fi

  nvim -d "$left" "$src" \
    -c "wincmd l" \
    -c "set noreadonly" \
    -c "echo 'Edit the RIGHT pane to produce the merged result. Save with :w, quit with :qa'"

  # Clean up temp file if we created one
  if [[ -n "$tmp_left" ]]; then
    rm -f "$tmp_left"
  fi
}

# Returns 0 if the symlink should be created, 1 if it should be skipped.
check_should_create() {
  local dest="$1"
  local src="$2"

  # Already correctly symlinked — idempotent, skip
  if [[ -L "$dest" ]]; then
    local current_target
    current_target=$(readlink "$dest")
    if [[ "$current_target" == "$src" ]]; then
      return 1
    fi
  fi

  # Dest exists but is not the correct symlink
  if [[ -e "$dest" ]] || [[ -L "$dest" ]]; then
    # Identical content — silently replace with symlink
    if [[ -f "$dest" ]] && [[ ! -L "$dest" ]] && cmp -s "$src" "$dest"; then
      echo "Replacing identical file with symlink: $dest"
      run_cmd rm -f "$dest"
      return 0
    fi

    if [[ $MERGE -eq 1 ]] && [[ -f "$dest" ]] && [[ ! -L "$dest" ]]; then
      merge_into_src "$dest" "$src"
      echo "Removing existing: $dest (replaced by merged dotfiles source)"
      run_cmd rm -f "$dest"
      return 0
    elif [[ $BACKUP -eq 1 ]]; then
      local backup_dest="${dest}.bak"
      local counter=1
      while [[ -e "$backup_dest" ]]; do
        backup_dest="${dest}.bak.${counter}"
        ((counter++))
      done
      echo "Backing up existing: $dest → $backup_dest"
      run_cmd mv "$dest" "$backup_dest"
      return 0
    elif [[ $FORCE -eq 1 ]]; then
      echo "Removing existing: $dest"
      run_cmd rm -rf "$dest"
      return 0
    else
      echo "conflict: '$dest' already exists. Use --merge, --backup, or --force to resolve."
      exit 1
    fi
  fi

  return 0
}

link_tree() {
  local src_root="$1"
  local dest_root="$2"
  run_cmd mkdir -p "$dest_root"
  while IFS= read -r src; do
    local rel="${src#"${src_root}/"}"
    local dest="$dest_root/$rel"
    if check_should_create "$dest" "$src"; then
      run_cmd mkdir -p "$(dirname "$dest")"
      run_cmd ln -s "$src" "$dest"
    fi
  done < <(find "$src_root" -type f)
}

# -----------------------------------------------------------------------------
# cd into repo root so relative paths work
# -----------------------------------------------------------------------------

cd "$(dirname "${BASH_SOURCE[0]}")"

DOTFILES_ROOT="$PWD/root"
DOTFILES_ROOT_ETC="$DOTFILES_ROOT/etc"
DOTFILES_HOME="$DOTFILES_ROOT/home"

suffix=""
[[ $DRY_RUN -eq 1 ]] && suffix=" (dry-run)"

# =============================================================================
# 1. PACKAGES (optional, --install)
# =============================================================================

if [[ $INSTALL -eq 1 ]]; then
  echo ">>> Installing packages..."
  if [[ -f "$PWD/install.sh" ]]; then
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "+ bash $PWD/install.sh"
    else
      bash "$PWD/install.sh"
    fi
  else
    echo "Error: install.sh not found at $PWD/install.sh"
    exit 1
  fi
else
  echo ">>> Skipping package installation (use --install to enable)"
fi

# =============================================================================
# 2. SYMLINK CONFIGS
# =============================================================================

echo ">>> Linking executables into ~/.local/bin"
link_tree "$DOTFILES_HOME/.local/bin" "$HOME/.local/bin"

if [[ -d "$DOTFILES_HOME/.local/lib" ]]; then
  echo ">>> Linking library scripts into ~/.local/lib"
  link_tree "$DOTFILES_HOME/.local/lib" "$HOME/.local/lib"
fi

if [[ -d "$DOTFILES_HOME/.local/share" ]]; then
  echo ">>> Linking shared files into ~/.local/share"
  link_tree "$DOTFILES_HOME/.local/share" "$HOME/.local/share"
fi

echo ">>> Linking config files into ~/.config"
link_tree "$DOTFILES_HOME/.config" "$HOME/.config"

echo ">>> Linking dotfiles into \$HOME"
while IFS= read -r src; do
  rel="${src#"$DOTFILES_HOME/"}"
  dest="$HOME/$rel"
  if check_should_create "$dest" "$src"; then
    run_cmd mkdir -p "$(dirname "$dest")"
    run_cmd ln -s "$src" "$dest"
  fi
done < <(find "$DOTFILES_HOME" -type f \
  ! -path "$DOTFILES_HOME/.config/*" \
  ! -path "$DOTFILES_HOME/.local/*")

# =============================================================================
# 3. PERMISSIONS
# =============================================================================

if [[ -d "$HOME/.ssh" ]];   then run_cmd chmod 700 "$HOME/.ssh";   fi
if [[ -d "$HOME/.gnupg" ]]; then run_cmd chmod 700 "$HOME/.gnupg"; fi

# Deploy /etc/hosts
if [[ -f "$DOTFILES_ROOT_ETC/hosts" ]]; then
  echo ">>> Deploying /etc/hosts"
  HOSTS_SRC="$DOTFILES_ROOT_ETC/hosts"
  HOSTS_DEST="/etc/hosts"

  if [[ -f "$HOSTS_DEST" ]] && cmp -s "$HOSTS_SRC" "$HOSTS_DEST"; then
    echo "/etc/hosts is already up to date"
  elif [[ $MERGE -eq 1 ]] && [[ -f "$HOSTS_DEST" ]]; then
    merge_into_src "$HOSTS_DEST" "$HOSTS_SRC"
    run_cmd sudo cp "$HOSTS_SRC" "$HOSTS_DEST"
    run_cmd sudo chown root:root "$HOSTS_DEST"
    run_cmd sudo chmod 644 "$HOSTS_DEST"
    echo "/etc/hosts deployed"
  elif [[ $BACKUP -eq 1 ]] && [[ -f "$HOSTS_DEST" ]]; then
    backup_dest="${HOSTS_DEST}.bak.$(date +%s)"
    echo "Backing up $HOSTS_DEST → $backup_dest"
    run_cmd sudo cp "$HOSTS_DEST" "$backup_dest"
    run_cmd sudo cp "$HOSTS_SRC" "$HOSTS_DEST"
    run_cmd sudo chown root:root "$HOSTS_DEST"
    run_cmd sudo chmod 644 "$HOSTS_DEST"
    echo "/etc/hosts deployed"
  elif [[ $FORCE -eq 1 ]] || [[ ! -f "$HOSTS_DEST" ]]; then
    run_cmd sudo cp "$HOSTS_SRC" "$HOSTS_DEST"
    run_cmd sudo chown root:root "$HOSTS_DEST"
    run_cmd sudo chmod 644 "$HOSTS_DEST"
    echo "/etc/hosts deployed"
  else
    echo "conflict: '$HOSTS_DEST' already exists. Use --merge, --backup, or --force."
    exit 1
  fi
fi

# Deploy power profile udev rule
if [[ -f "$DOTFILES_ROOT_ETC/udev/rules.d/99-power-profile.rules" ]]; then
  echo ">>> Installing power profile udev rule"
  UDEV_SRC="$DOTFILES_ROOT_ETC/udev/rules.d/99-power-profile.rules"
  UDEV_DEST="/etc/udev/rules.d/99-power-profile.rules"

  if [[ -f "$UDEV_DEST" ]] && cmp -s "$UDEV_SRC" "$UDEV_DEST"; then
    echo "Power profile udev rule already up to date"
  elif [[ $DRY_RUN -eq 1 ]]; then
    echo "+ sudo cp $UDEV_SRC $UDEV_DEST"
    echo "+ sudo udevadm control --reload-rules"
    echo "+ sudo udevadm trigger --subsystem-match=power_supply"
  else
    if sudo cp "$UDEV_SRC" "$UDEV_DEST"; then
      sudo udevadm control --reload-rules
      sudo udevadm trigger --subsystem-match=power_supply
      echo "Power profile udev rule installed"
    else
      echo "Warning: Failed to install udev rule — skipping"
    fi
  fi
fi

# =============================================================================
# 4. SYSTEMD SERVICES
# =============================================================================

echo ">>> Enabling systemd user services"

if [[ $DRY_RUN -eq 1 ]]; then
  echo "+ systemctl --user daemon-reload"
  echo "+ systemctl --user enable --now ssh-agent.service"
  echo "+ systemctl --user enable --now power-profile-switch.service"
  echo "+ systemctl --user enable --now battery-notify.timer"
else
  systemctl --user daemon-reload

  for svc in ssh-agent.service power-profile-switch.service; do
    if [[ -f "$HOME/.config/systemd/user/$svc" ]]; then
      systemctl --user enable --now "$svc" && echo "  enabled: $svc" \
        || echo "  Warning: failed to enable $svc"
    fi
  done

  if [[ -f "$HOME/.config/systemd/user/battery-notify.timer" ]]; then
    systemctl --user enable --now battery-notify.timer && echo "  enabled: battery-notify.timer" \
      || echo "  Warning: failed to enable battery-notify.timer"
  fi
fi

# =============================================================================
# 5. VPN (optional, --with-vpn)
# =============================================================================

if [[ $WITH_VPN -eq 1 ]]; then
  echo ">>> Setting up home VPN (WireGuard)"

  VPN_CONF_NAME="debbie-local"
  VPN_CONF_DEST="/etc/wireguard/${VPN_CONF_NAME}.conf"
  VPN_CONF_SEARCH=(
    "$HOME/Downloads/debbie.conf"
    "$PWD/debbie.conf"
  )

  if [[ -f "$VPN_CONF_DEST" ]]; then
    echo "VPN config already at $VPN_CONF_DEST — skipping"
  else
    VPN_CONF=""
    for candidate in "${VPN_CONF_SEARCH[@]}"; do
      if [[ -f "$candidate" ]]; then
        VPN_CONF="$candidate"
        break
      fi
    done

    if [[ -z "$VPN_CONF" ]]; then
      echo "Warning: debbie.conf not found (checked: ${VPN_CONF_SEARCH[*]})"
      echo "  Place it in ~/Downloads and re-run with --with-vpn to install."
    else
      echo "Found: $VPN_CONF"
      if [[ $DRY_RUN -eq 1 ]]; then
        echo "+ sudo install -o root -g root -m 600 \"$VPN_CONF\" \"$VPN_CONF_DEST\""
      else
        sudo install -o root -g root -m 600 "$VPN_CONF" "$VPN_CONF_DEST"
        echo "VPN '$VPN_CONF_NAME' installed"
        echo "  Connect with:     vpn up home"
        echo "  Autoconnect with: vpn autoconnect home"
      fi
    fi
  fi
else
  echo ">>> Skipping VPN setup (use --with-vpn to enable)"
fi

# =============================================================================
# 6. NAS SYNC (optional, --with-nas-sync)
# =============================================================================

if [[ $WITH_NAS_SYNC -eq 1 ]]; then
  echo ">>> Setting up NAS sync"
  run_cmd mkdir -p "$HOME/.config/nas-sync"

  PASSWORD_FILE="$HOME/.config/nas-sync/rsync-password"
  if [[ ! -f "$PASSWORD_FILE" ]] && [[ $DRY_RUN -eq 0 ]]; then
    echo "NAS rsync password file not found."
    echo "Please enter your NAS rsync password (or press Enter to skip):"
    read -s -r nas_password
    if [[ -n "$nas_password" ]]; then
      echo "$nas_password" > "$PASSWORD_FILE"
      chmod 600 "$PASSWORD_FILE"
      echo "Password file created at $PASSWORD_FILE"
    else
      echo "Skipping password setup. Create it later:"
      echo "  echo 'your_password' > $PASSWORD_FILE && chmod 600 $PASSWORD_FILE"
    fi
  elif [[ -f "$PASSWORD_FILE" ]]; then
    echo "Password file already exists"
  fi

  if [[ $DRY_RUN -eq 0 ]]; then
    echo ">>> Performing initial clone from NAS"
    if "$HOME/.local/lib/check-nas-connection"; then
      echo "NAS is reachable, cloning data..."
      mkdir -p "$HOME/Documents" "$HOME/Music" "$HOME/Photos" "$HOME/Audiobooks" "$HOME/Books"

      for sync_info in "documents:Documents" "music:Music" "photos:Photos" "audiobooks:Audiobooks" "books:Books"; do
        module="${sync_info%%:*}"
        local_dir="${sync_info##*:}"
        echo "Cloning $module → ~/$local_dir..."
        rsync -avz --progress --password-file="$PASSWORD_FILE" \
          "rsync://nate@nas.lan:873/$module/" "$HOME/$local_dir/" \
          || echo "Warning: Failed to clone $module — continuing..."
      done
      echo "Initial clone complete"
    else
      echo "Warning: NAS not reachable — skipping initial clone."
      echo "  Run manually: rsync -avz --password-file=$PASSWORD_FILE rsync://nate@nas.lan:873/documents/ \$HOME/Documents/"
    fi

    echo ">>> Enabling NAS sync timers"
    systemctl --user daemon-reload
    for sync_type in documents music photos audiobooks books; do
      systemctl --user enable --now "nas-sync-${sync_type}.timer" \
        && echo "  enabled: nas-sync-${sync_type}.timer" \
        || echo "  Warning: failed to enable nas-sync-${sync_type}.timer"
    done
    echo "Check timers: systemctl --user list-timers"
  else
    echo "+ check-nas-connection"
    echo "+ mkdir -p ~/Documents ~/Music ~/Photos ~/Audiobooks ~/Books"
    for sync_type in documents music photos audiobooks books; do
      echo "+ rsync -avz --password-file=$HOME/.config/nas-sync/rsync-password rsync://nate@nas.lan:873/${sync_type}/ ~/${sync_type^}/"
      echo "+ systemctl --user enable --now nas-sync-${sync_type}.timer"
    done
  fi
else
  echo ">>> Skipping NAS sync (use --with-nas-sync to enable)"
fi

# =============================================================================

echo ">>> Done${suffix}."
