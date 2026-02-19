#!/usr/bin/env bash
# install.sh — install packages, symlink dotfiles, enable services, set up VPN/NAS
#
# Order of operations:
#   1. Packages    (Arch Linux packages via pacman/yay; skip with --skip-packages)
#   2. Symlinks    (bins, libs, share, config files, dotfiles, /etc files)
#   3. Permissions (.ssh, .gnupg)
#   4. systemd     (daemon-reload, enable user services)
#   5. VPN         (--with-vpn: install WireGuard config)
#   6. NAS sync    (--with-nas-sync: initial clone + enable timers)

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DRY_RUN=0
FORCE=0
BACKUP=0
MERGE=0
WITH_VPN=0
WITH_NAS_SYNC=0
SKIP_PACKAGES=0

usage() {
  cat <<EOF
Usage: $0 [--dry-run|-n] [--force|-f] [--backup|-b] [--merge|-m] [--with-vpn] [--with-nas-sync] [--skip-packages]

  --dry-run, -n       Print the commands that would be run, but do not execute them.
  --force, -f         Remove existing files/symlinks before creating new ones.
  --backup, -b        Backup existing files/symlinks by renaming them with .bak suffix.
  --merge, -m         On conflict, open nvim diff to merge existing file into the dotfiles
                      source, then symlink. Saves merged result back into the dotfiles repo.
  --with-vpn          Install WireGuard config to /etc/wireguard/ (optional).
  --with-nas-sync     Enable NAS sync timers setup (optional).
  --skip-packages     Skip Arch Linux package installation.
  --help, -h          Show this help message.
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case $1 in
  -n | --dry-run)      DRY_RUN=1;        shift ;;
  -f | --force)        FORCE=1;          shift ;;
  -b | --backup)       BACKUP=1;         shift ;;
  -m | --merge)        MERGE=1;          shift ;;
  --with-vpn)          WITH_VPN=1;       shift ;;
  --with-nas-sync)     WITH_NAS_SYNC=1;  shift ;;
  --skip-packages)     SKIP_PACKAGES=1;  shift ;;
  -h | --help)         usage ;;
  *)                   usage ;;
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

# Ensure submodules (e.g. omarchy) are initialised and up to date
git submodule update --init --recursive

DOTFILES_ROOT="$PWD/root"
DOTFILES_ROOT_ETC="$DOTFILES_ROOT/etc"
DOTFILES_HOME="$DOTFILES_ROOT/home"

suffix=""
[[ $DRY_RUN -eq 1 ]] && suffix=" (dry-run)"

# =============================================================================
# 1. PACKAGES
# =============================================================================

if [[ $SKIP_PACKAGES -eq 1 ]]; then
  echo ">>> Skipping package installation (--skip-packages)"
else
  echo -e "${BLUE}============================================${NC}"
  echo -e "${BLUE}Arch Linux Package Installation${NC}"
  echo -e "${BLUE}============================================${NC}"
  echo ""

  # Check if running on Arch Linux
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
    arch | manjaro | endeavouros)
      echo -e "${GREEN}✓${NC} Detected: $NAME"
      ;;
    *)
      echo -e "${RED}✗${NC} This script only supports Arch Linux"
      exit 1
      ;;
    esac
  else
    echo -e "${RED}✗${NC} Cannot detect distribution"
    exit 1
  fi

  echo ""

  if [[ $DRY_RUN -eq 1 ]]; then
    echo "+ sudo pacman -Syu --noconfirm"
  else
    echo -e "${BLUE}>>> Updating system packages...${NC}"
    sudo pacman -Syu --noconfirm
    echo ""
  fi

  # Install yay if not present
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "+ yay (AUR helper) — would install if missing"
  elif ! command -v yay &>/dev/null; then
    echo -e "${BLUE}>>> Installing yay (AUR helper)...${NC}"
    sudo pacman -S --needed --noconfirm git base-devel
    TMP_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$TMP_DIR/yay"
    (cd "$TMP_DIR/yay" && makepkg -si --noconfirm)
    rm -rf "$TMP_DIR"
    echo -e "${GREEN}✓${NC} yay installed"
    echo ""
  else
    echo -e "${GREEN}✓${NC} yay already installed"
    echo ""
  fi

  if [[ $DRY_RUN -eq 1 ]]; then
    echo "+ sudo pacman -S --needed --noconfirm git curl wget base-devel linux-headers"
    echo "+ sudo pacman -S --needed --noconfirm linux-hardened linux-hardened-headers linux-lts linux-lts-headers"
    echo "+ sudo pacman -S --needed --noconfirm apparmor"
    echo "+ yay -S --needed --noconfirm apparmor.d"
    echo "+ sudo pacman -S --needed --noconfirm fish fzf ripgrep fd bat eza dust btop fastfetch jq wl-clipboard"
    echo "+ sudo pacman -S --needed --noconfirm neovim docker docker-compose github-cli git-delta"
    echo "+ yay -S --needed --noconfirm lazygit lazydocker act"
    echo "+ sudo pacman -S --needed --noconfirm flatpak"
    echo "+ flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
    echo "+ yay -S --needed --noconfirm librewolf-bin"
    echo "+ sudo pacman -S --needed --noconfirm power-profiles-daemon fwupd openssh wireguard-tools openresolv rsync"
    echo "+ sudo systemctl enable --now docker.service"
    echo "+ sudo usermod -aG docker $USER"
    echo "+ sudo systemctl enable --now power-profiles-daemon.service"
    echo "+ sudo systemctl enable apparmor.service"
  else
    echo -e "${BLUE}>>> Installing core packages...${NC}"
    sudo pacman -S --needed --noconfirm \
      git \
      curl \
      wget \
      base-devel \
      linux-headers
    echo ""

    echo -e "${BLUE}>>> Installing hardened kernels...${NC}"
    sudo pacman -S --needed --noconfirm \
      linux-hardened \
      linux-hardened-headers \
      linux-lts \
      linux-lts-headers
    echo -e "${GREEN}✓${NC} Hardened and LTS kernels installed"
    echo ""

    echo -e "${BLUE}>>> Installing AppArmor security framework...${NC}"
    sudo pacman -S --needed --noconfirm apparmor
    yay -S --needed --noconfirm apparmor.d
    echo -e "${GREEN}✓${NC} AppArmor installed with comprehensive profiles"
    echo ""

    echo -e "${BLUE}>>> Installing shell utilities...${NC}"
    sudo pacman -S --needed --noconfirm \
      fish \
      fzf \
      ripgrep \
      fd \
      bat \
      eza \
      dust \
      btop \
      fastfetch \
      jq \
      wl-clipboard
    echo ""

    echo -e "${BLUE}>>> Installing development tools...${NC}"
    sudo pacman -S --needed --noconfirm \
      neovim \
      docker \
      docker-compose \
      github-cli \
      git-delta
    yay -S --needed --noconfirm \
      lazygit \
      lazydocker \
      act
    echo ""

    echo -e "${BLUE}>>> Installing flatpak...${NC}"
    sudo pacman -S --needed --noconfirm flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo ""

    echo -e "${BLUE}>>> Installing desktop applications...${NC}"
    yay -S --needed --noconfirm librewolf-bin
    echo ""

    echo -e "${BLUE}>>> Installing system utilities...${NC}"
    sudo pacman -S --needed --noconfirm \
      power-profiles-daemon \
      fwupd \
      openssh \
      wireguard-tools \
      openresolv \
      rsync
    echo ""

    echo -e "${BLUE}>>> Enabling system services...${NC}"
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
    sudo usermod -aG docker "$USER"
    echo -e "${GREEN}✓${NC} Docker enabled"

    sudo systemctl enable power-profiles-daemon.service
    sudo systemctl start power-profiles-daemon.service
    echo -e "${GREEN}✓${NC} Power profiles daemon enabled"

    sudo systemctl enable apparmor.service
    echo -e "${GREEN}✓${NC} AppArmor enabled"
    echo ""

    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}Package Installation Complete!${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo -e "${YELLOW}⚠${NC} Please log out and back in for group changes to take effect"
    echo ""
  fi
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
# 2b. OMARCHY SUBMODULE → ~/.local/share/omarchy
# =============================================================================

echo ">>> Linking omarchy submodule into ~/.local/share/omarchy"

OMARCHY_SRC="$PWD/omarchy"
OMARCHY_DEST="$HOME/.local/share/omarchy"

if [[ -d "$OMARCHY_SRC" ]]; then
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "+ backup/remove $OMARCHY_DEST if it exists and is not already the correct symlink"
    echo "+ ln -sfn $OMARCHY_SRC $OMARCHY_DEST"
  else
    # Already correctly symlinked — nothing to do
    if [[ -L "$OMARCHY_DEST" ]] && [[ "$(readlink "$OMARCHY_DEST")" == "$OMARCHY_SRC" ]]; then
      echo "  already symlinked — skipping"
    else
      # Back up any existing real directory
      if [[ -d "$OMARCHY_DEST" && ! -L "$OMARCHY_DEST" ]]; then
        OMARCHY_BACKUP="${OMARCHY_DEST}.bak.$(date +%s)"
        echo "  backing up existing $OMARCHY_DEST → $OMARCHY_BACKUP"
        mv "$OMARCHY_DEST" "$OMARCHY_BACKUP"
      elif [[ -L "$OMARCHY_DEST" ]]; then
        # Wrong symlink target — remove it
        rm "$OMARCHY_DEST"
      fi
      run_cmd mkdir -p "$HOME/.local/share"
      run_cmd ln -sfn "$OMARCHY_SRC" "$OMARCHY_DEST"
      echo "  linked: $OMARCHY_DEST → $OMARCHY_SRC"
    fi
  fi
else
  echo "  warning: omarchy submodule not found at $OMARCHY_SRC — skipping"
fi

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

# Configure AppArmor kernel parameters
echo ">>> Configuring AppArmor kernel parameters"
LIMINE_CONFIG="/etc/default/limine"
APPARMOR_PARAM="lsm=landlock,lockdown,yama,integrity,apparmor,bpf"

if [[ -f "$LIMINE_CONFIG" ]]; then
  if grep -q "KERNEL_CMDLINE.*${APPARMOR_PARAM}" "$LIMINE_CONFIG"; then
    echo "AppArmor kernel parameters already configured"
  elif [[ $DRY_RUN -eq 1 ]]; then
    echo "+ sudo sed -i '/KERNEL_CMDLINE\[default\]+=\"quiet splash\"/a KERNEL_CMDLINE[default]+=\" $APPARMOR_PARAM\"' $LIMINE_CONFIG"
    echo "+ sudo limine-mkinitcpio"
  else
    echo "Adding AppArmor LSM parameter to Limine config..."
    if sudo sed -i "/KERNEL_CMDLINE\[default\]+=\"quiet splash\"/a KERNEL_CMDLINE[default]+=\" ${APPARMOR_PARAM}\"" "$LIMINE_CONFIG"; then
      echo "Regenerating boot configuration with AppArmor..."
      sudo limine-mkinitcpio
      echo -e "\n${YELLOW}⚠ Reboot required for AppArmor to be active${NC}"
    else
      echo "Warning: Failed to configure AppArmor kernel parameters"
    fi
  fi
else
  echo "Note: $LIMINE_CONFIG not found - skipping AppArmor kernel parameters"
  echo "  If using a different bootloader, add this kernel parameter manually:"
  echo "  $APPARMOR_PARAM"
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
