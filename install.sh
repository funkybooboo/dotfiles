#!/usr/bin/env bash
# install.sh — install packages, symlink dotfiles, enable services, set up VPN/NAS
#
# Order of operations:
#   0. Preflight   (distro check, not-root, internet, git submodules)
#   1. Packages    (pacman/yay; skip with --skip-packages)
#   2. Symlinks    (bins, libs, share, configs, dotfiles, /etc files)
#   3. Permissions (.ssh, .gnupg, /etc/hosts, udev, AppArmor)
#   4. systemd     (daemon-reload, enable user services)
#   5. VPN         (--with-vpn: install WireGuard config)
#   6. NAS sync    (--with-nas-sync: initial clone + enable timers)

set -euo pipefail

# =============================================================================
# COLORS & OUTPUT HELPERS
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $*"; }
fail() { echo -e "  ${RED}✗${NC} $*"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $*"; }
info() { echo -e "  ${BLUE}→${NC} $*"; }
skip() { echo -e "  ${DIM}–${NC} ${DIM}$*${NC}"; }

section() {
  echo ""
  echo -e "${BOLD}${CYAN}══════════════════════════════════════════${NC}"
  echo -e "${BOLD}${CYAN}  $*${NC}"
  echo -e "${BOLD}${CYAN}══════════════════════════════════════════${NC}"
}

# Summary tracking — collected and printed at the end
WARNINGS=()
ERRORS=()
_add_warning() { WARNINGS+=("$1"); }
_add_error()   { ERRORS+=("$1"); }

# =============================================================================
# FLAGS
# =============================================================================

DRY_RUN=0
FORCE=0
BACKUP=0
MERGE=0
RESTORE=0
WITH_VPN=0
WITH_NAS_SYNC=0
SKIP_PACKAGES=0

usage() {
  echo -e "${BOLD}Usage:${NC} $0 [options]"
  echo ""
  echo -e "${BOLD}Conflict resolution (pick one):${NC}"
  echo -e "  --backup,  -b   Backup conflicting files with .bak suffix  ${GREEN}(recommended)${NC}"
  echo -e "  --merge,   -m   Open nvim diff — edit the ${BOLD}RIGHT pane${NC} (dotfiles source), which is saved and symlinked"
  echo -e "  --force,   -f   Remove conflicting files/symlinks  ${RED}(destructive)${NC}"
  echo ""
  echo -e "${BOLD}Options:${NC}"
  echo -e "  --restore,  -r  Undo installation by restoring .bak files and removing symlinks"
  echo -e "  --dry-run,  -n  Preview all actions without executing"
  echo -e "  --skip-packages Skip package installation (symlinks/services only)"
  echo -e "  --with-vpn      Install WireGuard config to /etc/wireguard/"
  echo -e "  --with-nas-sync Enable hourly NAS rsync timers"
  echo -e "  --help,     -h  Show this help message"
  echo ""
  echo -e "${BOLD}Common invocations:${NC}"
  echo -e "  $0 --dry-run                           ${DIM}# preview without changes${NC}"
  echo -e "  $0 --backup                            ${DIM}# fresh install${NC}"
  echo -e "  $0 --skip-packages --backup            ${DIM}# re-symlink only${NC}"
  echo -e "  $0 --backup --with-vpn --with-nas-sync ${DIM}# full install${NC}"
  echo -e "  $0 --restore --dry-run                 ${DIM}# preview restore${NC}"
  echo -e "  $0 --restore                           ${DIM}# undo installation${NC}"
  exit 0
}

while [[ $# -gt 0 ]]; do
  case $1 in
  -n | --dry-run)      DRY_RUN=1;        shift ;;
  -f | --force)        FORCE=1;          shift ;;
  -b | --backup)       BACKUP=1;         shift ;;
  -m | --merge)        MERGE=1;          shift ;;
  -r | --restore)      RESTORE=1;        shift ;;
  --with-vpn)          WITH_VPN=1;       shift ;;
  --with-nas-sync)     WITH_NAS_SYNC=1;  shift ;;
  --skip-packages)     SKIP_PACKAGES=1;  shift ;;
  -h | --help)         usage ;;
  *)
    echo -e "${RED}✗ Unknown option: $1${NC}"
    echo -e "  Run '$0 --help' for usage."
    exit 1
    ;;
  esac
done

# Validate: only one conflict resolution mode at a time
conflict_flags=$(( MERGE + BACKUP + FORCE ))
if [[ $conflict_flags -gt 1 ]]; then
  echo -e "${RED}✗ Only one of --merge, --backup, --force may be specified.${NC}"
  exit 1
fi

# Validate: --restore is mutually exclusive with install-related flags
if [[ $RESTORE -eq 1 ]]; then
  if [[ $conflict_flags -gt 0 ]] || [[ $WITH_VPN -eq 1 ]] || [[ $WITH_NAS_SYNC -eq 1 ]] || [[ $SKIP_PACKAGES -eq 1 ]]; then
    echo -e "${RED}✗ --restore cannot be combined with install flags (--backup, --merge, --force, --with-vpn, --with-nas-sync, --skip-packages).${NC}"
    echo -e "  Use: $0 --restore [--dry-run]"
    exit 1
  fi
fi

# =============================================================================
# CORE HELPERS
# =============================================================================

# Run a command for real, or print it dimmed in dry-run mode.
run_cmd() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo -e "  ${DIM}+ $*${NC}"
  else
    "$@"
  fi
}

# Enable a systemd user service idempotently.
# Skips silently if already enabled; warns on failure.
enable_user_service() {
  local unit="$1"
  local unit_file="$HOME/.config/systemd/user/$unit"

  if [[ ! -f "$unit_file" ]]; then
    skip "$unit (unit file not found — run install first)"
    return
  fi

  if [[ $DRY_RUN -eq 1 ]]; then
    info "would enable: $unit"
    return
  fi

  if systemctl --user is-enabled --quiet "$unit" 2>/dev/null; then
    systemctl --user start "$unit" 2>/dev/null || true
    skip "$unit (already enabled)"
  else
    if systemctl --user enable --now "$unit" 2>/dev/null; then
      ok "enabled: $unit"
    else
      warn "failed to enable $unit"
      _add_warning "systemd unit failed to enable: $unit"
    fi
  fi
}

# Open nvim diff to merge the existing system file (left, read-only) into the
# dotfiles source (right, editable). The right pane is saved back to the repo
# and then symlinked — the left pane is read-only reference only.
#
# Creates a .bak file before merging so --restore can undo the merge.
# If dest is root-owned and unreadable, it is copied to a temp file first.
merge_into_src() {
  local dest="$1"
  local src="$2"

  # Create backup before merge (for --restore)
  if [[ -f "$dest" ]] && [[ ! -L "$dest" ]]; then
    local backup="${dest}.bak"
    if [[ $DRY_RUN -eq 0 ]]; then
      if [[ -r "$dest" ]]; then
        cp "$dest" "$backup"
        info "created backup: ${backup/$HOME/\~}"
      else
        # Root-owned file — use sudo
        sudo cp "$dest" "$backup"
        info "created backup: $backup (with sudo)"
      fi
    fi
  fi

  info "Merging: $dest → $src"
  echo -e "    ${DIM}Left  (read-only) : existing system file${NC}"
  echo -e "    ${DIM}Right (edit this) : dotfiles source — ${NC}${BOLD}this pane is saved back to the repo and symlinked${NC}"

  local left="$dest"
  local tmp_left=""

  if [[ ! -r "$dest" ]]; then
    tmp_left=$(mktemp)
    sudo cp "$dest" "$tmp_left"
    sudo chmod 644 "$tmp_left"
    left="$tmp_left"
  fi

  nvim -d "$left" "$src" \
    -c "wincmd l" \
    -c "set noreadonly" \
    -c "echo 'RIGHT pane = dotfiles source — edit here, :w to save (this file gets symlinked), :qa to quit'"

  [[ -n "$tmp_left" ]] && rm -f "$tmp_left"
}

# =============================================================================
# SYMLINK HELPERS
# =============================================================================

# Returns all submodule paths listed in .gitmodules (relative to repo root).
_submodule_paths() {
  if [[ ! -f .gitmodules ]]; then
    return 0
  fi
  git config --file .gitmodules --get-regexp 'submodule\..*\.path' \
    | awk '{print $2}'
}

# _resolve_conflict <dest> <src>
#   Handles an existing file/symlink at dest before linking src → dest.
#   Returns 0 to proceed with linking, 1 to skip (already correct or error).
_resolve_conflict() {
  local dest="$1"
  local src="$2"

  # Already correctly symlinked — idempotent, skip silently
  if [[ -L "$dest" ]]; then
    local current_target
    current_target=$(readlink "$dest")
    if [[ "$current_target" == "$src" ]]; then
      return 1
    fi
  fi

  # Nothing at dest — proceed
  if [[ ! -e "$dest" ]] && [[ ! -L "$dest" ]]; then
    return 0
  fi

  # Real file with identical content — silently replace with symlink
  if [[ -f "$dest" ]] && [[ ! -L "$dest" ]] && cmp -s "$src" "$dest"; then
    if [[ $DRY_RUN -eq 0 ]]; then
      info "replacing identical file with symlink: ${dest/$HOME/\~}"
      rm -f "$dest"
    fi
    return 0
  fi

  # Conflict: apply chosen resolution strategy
  if [[ $MERGE -eq 1 ]] && [[ -f "$dest" ]] && [[ ! -L "$dest" ]]; then
    merge_into_src "$dest" "$src"
    run_cmd rm -f "$dest"
    return 0
  elif [[ $BACKUP -eq 1 ]]; then
    local backup_dest="${dest}.bak"
    local counter=1
    while [[ -e "$backup_dest" ]]; do
      backup_dest="${dest}.bak.${counter}"
      ((counter++))
    done
    info "backing up: ${dest/$HOME/\~} → ${backup_dest/$HOME/\~}"
    run_cmd mv "$dest" "$backup_dest"
    return 0
  elif [[ $FORCE -eq 1 ]]; then
    info "removing: ${dest/$HOME/\~}"
    run_cmd rm -rf "$dest"
    return 0
  else
    fail "conflict: '${dest/$HOME/\~}' already exists"
    _add_error "conflict: '$dest' — use --backup, --merge, or --force"
    return 1
  fi
}

# link_tree <src_root> <dest_root>
#   Symlinks individual files from src_root into dest_root, preserving
#   directory structure. Submodule directories are skipped automatically
#   (use link_dir for those instead).
link_tree() {
  local src_root="$1"
  local dest_root="$2"

  # Build find exclusions for any submodule dirs under src_root
  local find_args=(find "$src_root" -type f)
  while IFS= read -r submod; do
    local abs_submod="$REPO_ROOT/$submod"
    if [[ "$abs_submod" == "$src_root/"* ]]; then
      find_args+=(-not -path "$abs_submod/*")
    fi
  done < <(_submodule_paths)

  [[ $DRY_RUN -eq 0 ]] && mkdir -p "$dest_root"

  while IFS= read -r src; do
    local rel="${src#"${src_root}/"}"
    local dest="$dest_root/$rel"
    if _resolve_conflict "$dest" "$src"; then
      if [[ $DRY_RUN -eq 1 ]]; then
        echo -e "  ${DIM}+ ln -s $src $dest${NC}"
      else
        mkdir -p "$(dirname "$dest")"
        ln -s "$src" "$dest"
      fi
    fi
  done < <("${find_args[@]}")
}

# link_dir <src> <dest>
#   Symlinks an entire directory as a single unit (used for submodules so
#   their internal .git reference stays intact).
link_dir() {
  local src="$1"
  local dest="$2"

  if [[ $DRY_RUN -eq 1 ]]; then
    info "would link dir: ${dest/$HOME/\~} → $src"
    return
  fi

  # Already correctly symlinked — nothing to do
  if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
    return
  fi

  if [[ -e "$dest" ]] || [[ -L "$dest" ]]; then
    if [[ $BACKUP -eq 1 ]] || [[ $MERGE -eq 1 ]]; then
      local bak="${dest}.bak.$(date +%s)"
      info "backing up: ${dest/$HOME/\~} → ${bak/$HOME/\~}"
      mv "$dest" "$bak"
    elif [[ $FORCE -eq 1 ]]; then
      info "removing: ${dest/$HOME/\~}"
      rm -rf "$dest"
    else
      fail "conflict: '${dest/$HOME/\~}' already exists"
      _add_error "conflict: '$dest' — use --backup or --force"
      return
    fi
  fi

  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
  ok "linked dir: ${dest/$HOME/\~}"
}

# =============================================================================
# cd into repo root so all relative paths work
# =============================================================================

cd "$(dirname "${BASH_SOURCE[0]}")"
REPO_ROOT="$PWD"
DOTFILES_ROOT="$REPO_ROOT/root"
DOTFILES_ROOT_ETC="$DOTFILES_ROOT/etc"
DOTFILES_HOME="$DOTFILES_ROOT/home"

# =============================================================================
# RESTORE MODE
# =============================================================================

# restore_dotfiles — reverses installation by restoring .bak files
restore_dotfiles() {
  section "Restore Mode"
  
  info "scanning for symlinks pointing to ~/dotfiles..."
  
  local restored_count=0
  local orphaned_count=0
  
  # Restore $HOME files
  while IFS= read -r src; do
    local rel="${src#"$DOTFILES_HOME/"}"
    local dest="$HOME/$rel"
    local backup="${dest}.bak"
    
    # Check if dest is a symlink pointing to our src
    if [[ -L "$dest" ]]; then
      local target
      target=$(readlink "$dest")
      if [[ "$target" == "$src" ]]; then
        # Found our symlink — check for backup
        if [[ -e "$backup" ]]; then
          info "restoring: ${dest/$HOME/\~}"
          run_cmd rm "$dest"
          run_cmd mv "$backup" "$dest"
          [[ $DRY_RUN -eq 0 ]] && ok "restored: ${dest/$HOME/\~}"
          ((restored_count++))
        fi
      fi
    # Check for orphaned backups (backup exists but no symlink)
    elif [[ ! -L "$dest" ]] && [[ -e "$backup" ]]; then
      warn "orphaned backup: ${backup/$HOME/\~} (no symlink found)"
      ((orphaned_count++))
    fi
  done < <(find "$DOTFILES_HOME" -type f \
    ! -path "$DOTFILES_HOME/.local/share/omarchy/*") || true
  
  # Restore directory symlinks (submodules)
  while IFS= read -r submod; do
    local_share_prefix="root/home/.local/share/"
    if [[ "$submod" == "$local_share_prefix"* ]]; then
      rel="${submod#root/home/}"
      dest="$HOME/$rel"
      backup="${dest}.bak"
      
      if [[ -L "$dest" ]]; then
        target=$(readlink "$dest")
        if [[ "$target" == "$REPO_ROOT/$submod" ]]; then
          # Check for timestamped backups (dir.bak.TIMESTAMP)
          local newest_backup=""
          for bak in "${dest}.bak"*; do
            [[ -e "$bak" ]] && newest_backup="$bak"
          done
          
          if [[ -n "$newest_backup" ]]; then
            info "restoring directory: ${dest/$HOME/\~}"
            run_cmd rm "$dest"
            run_cmd mv "$newest_backup" "$dest"
            [[ $DRY_RUN -eq 0 ]] && ok "restored: ${dest/$HOME/\~}"
            ((restored_count++))
          fi
        fi
      elif [[ ! -L "$dest" ]] && [[ -e "$backup" ]]; then
        warn "orphaned backup: ${backup/$HOME/\~} (no symlink found)"
        ((orphaned_count++))
      fi
    fi
  done < <(_submodule_paths) || true
  
  # Restore /etc/hosts
  if [[ -f "$DOTFILES_ROOT_ETC/hosts" ]]; then
    HOSTS_DEST="/etc/hosts"
    if [[ -L "$HOSTS_DEST" ]]; then
      target=$(readlink "$HOSTS_DEST")
      if [[ "$target" == "$DOTFILES_ROOT_ETC/hosts" ]]; then
        # Find newest backup (timestamped)
        local newest_hosts_backup=""
        for bak in "${HOSTS_DEST}.bak"*; do
          [[ -f "$bak" ]] && newest_hosts_backup="$bak"
        done
        
        if [[ -n "$newest_hosts_backup" ]]; then
          info "restoring /etc/hosts (requires sudo)"
          run_cmd sudo rm "$HOSTS_DEST"
          run_cmd sudo mv "$newest_hosts_backup" "$HOSTS_DEST"
          [[ $DRY_RUN -eq 0 ]] && ok "restored: /etc/hosts"
          ((restored_count++))
        fi
      fi
    fi
  fi
  
  # Restore /etc/udev rule
  UDEV_SRC="$DOTFILES_ROOT_ETC/udev/rules.d/99-power-profile.rules"
  UDEV_DEST="/etc/udev/rules.d/99-power-profile.rules"
  if [[ -f "$UDEV_SRC" ]] && [[ -f "$UDEV_DEST" ]]; then
    # Check if it was installed by us (content matches)
    if cmp -s "$UDEV_SRC" "$UDEV_DEST"; then
      local newest_udev_backup=""
      for bak in "${UDEV_DEST}.bak"*; do
        [[ -f "$bak" ]] && newest_udev_backup="$bak"
      done
      
      if [[ -n "$newest_udev_backup" ]]; then
        info "restoring udev rule (requires sudo)"
        run_cmd sudo mv "$newest_udev_backup" "$UDEV_DEST"
        run_cmd sudo udevadm control --reload-rules
        [[ $DRY_RUN -eq 0 ]] && ok "restored: udev rule"
        ((restored_count++))
      fi
    fi
  fi
  
  # Summary
  echo ""
  echo -e "${BOLD}${CYAN}══════════════════════════════════════════${NC}"
  echo -e "${BOLD}${CYAN}  Summary${NC}"
  echo -e "${BOLD}${CYAN}══════════════════════════════════════════${NC}"
  
  if [[ $DRY_RUN -eq 1 ]]; then
    echo -e "\n  ${YELLOW}Dry run complete — no changes were made${NC}"
  fi
  
  echo ""
  if [[ $restored_count -gt 0 ]]; then
    ok "Restored $restored_count file(s)"
  else
    info "No backups found to restore"
  fi
  
  if [[ $orphaned_count -gt 0 ]]; then
    warn "$orphaned_count orphaned backup(s) found (manual cleanup needed)"
  fi
  
  echo ""
  exit 0
}

# =============================================================================
# 0. PREFLIGHT
# =============================================================================

# If --restore flag is set, run restore mode and exit
if [[ $RESTORE -eq 1 ]]; then
  restore_dotfiles
fi

section "Preflight Checks"

# Must not run as root — sudo is called internally where needed
if [[ $EUID -eq 0 ]]; then
  fail "Do not run as root. Run as your normal user (sudo is called internally where needed)."
  exit 1
fi
ok "not running as root"

# Arch Linux (or compatible derivative) required
if [[ -f /etc/os-release ]]; then
  # shellcheck source=/dev/null
  . /etc/os-release
  case "${ID:-}" in
  arch | manjaro | endeavouros)
    ok "distro: $NAME"
    ;;
  *)
    fail "unsupported distro: ${NAME:-unknown} — Arch Linux required"
    exit 1
    ;;
  esac
else
  fail "cannot detect distro (/etc/os-release not found)"
  exit 1
fi

# Warn if no conflict resolution flag is set (and this isn't a dry-run)
if [[ $conflict_flags -eq 0 ]] && [[ $DRY_RUN -eq 0 ]]; then
  warn "no conflict resolution flag set — will abort on any conflict"
  warn "consider re-running with --backup (recommended)"
fi

# Internet check — only required when installing packages
if [[ $SKIP_PACKAGES -eq 0 ]]; then
  if ping -c1 -W2 archlinux.org &>/dev/null; then
    ok "internet connectivity"
  else
    fail "no internet connection — required for package installation"
    echo -e "\n  ${DIM}Tip: use --skip-packages to skip package installation${NC}"
    exit 1
  fi
fi

# Initialise git submodules (e.g. omarchy fork)
info "initialising git submodules..."
if git submodule update --init --recursive --quiet; then
  ok "submodules up to date"
else
  warn "submodule init had issues — continuing anyway"
  _add_warning "git submodule update had a non-zero exit"
fi

if [[ $DRY_RUN -eq 1 ]]; then
  echo ""
  echo -e "  ${YELLOW}DRY RUN — no changes will be made${NC}"
fi

# =============================================================================
# 1. PACKAGES
# =============================================================================

if [[ $SKIP_PACKAGES -eq 1 ]]; then
  section "Packages  [skipped]"
  skip "package installation skipped (--skip-packages)"
else
  section "Package Installation"

  # System update
  info "updating system packages..."
  run_cmd sudo pacman -Syu --noconfirm
  [[ $DRY_RUN -eq 0 ]] && ok "system updated"

  # Install yay (AUR helper) if not already present
  if command -v yay &>/dev/null; then
    skip "yay already installed"
  elif [[ $DRY_RUN -eq 1 ]]; then
    info "would install yay (AUR helper)"
  else
    info "installing yay (AUR helper)..."
    sudo pacman -S --needed --noconfirm git base-devel
    yay_tmp=$(mktemp -d)
    git clone --quiet https://aur.archlinux.org/yay.git "$yay_tmp/yay"
    (cd "$yay_tmp/yay" && makepkg -si --noconfirm)
    rm -rf "$yay_tmp"
    ok "yay installed"
  fi

  # ── Core ──────────────────────────────────────────────────────────────────
  info "installing core packages..."
  run_cmd sudo pacman -S --needed --noconfirm \
    git curl wget base-devel linux-headers
  [[ $DRY_RUN -eq 0 ]] && ok "core packages"

  # ── Security ──────────────────────────────────────────────────────────────
  info "installing hardened kernels..."
  run_cmd sudo pacman -S --needed --noconfirm \
    linux-hardened linux-hardened-headers \
    linux-lts linux-lts-headers
  [[ $DRY_RUN -eq 0 ]] && ok "hardened + LTS kernels"

  info "installing AppArmor..."
  run_cmd sudo pacman -S --needed --noconfirm apparmor
  run_cmd yay -S --needed --noconfirm apparmor.d
  [[ $DRY_RUN -eq 0 ]] && ok "AppArmor + 2000+ profiles"

  # ── Shell utilities ────────────────────────────────────────────────────────
  info "installing shell utilities..."
  run_cmd sudo pacman -S --needed --noconfirm \
    fish fzf ripgrep fd bat eza dust btop fastfetch jq wl-clipboard
  [[ $DRY_RUN -eq 0 ]] && ok "shell utilities"

  # ── Dev tools ─────────────────────────────────────────────────────────────
  info "installing dev tools..."
  run_cmd sudo pacman -S --needed --noconfirm \
    neovim docker docker-compose github-cli git-delta
  run_cmd yay -S --needed --noconfirm lazygit lazydocker act
  [[ $DRY_RUN -eq 0 ]] && ok "dev tools"

  # ── Desktop ───────────────────────────────────────────────────────────────
  info "installing flatpak..."
  run_cmd sudo pacman -S --needed --noconfirm flatpak
  run_cmd flatpak remote-add --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo
  [[ $DRY_RUN -eq 0 ]] && ok "flatpak + flathub remote"

  info "installing LibreWolf..."
  run_cmd yay -S --needed --noconfirm librewolf-bin
  [[ $DRY_RUN -eq 0 ]] && ok "LibreWolf"

  # ── System utilities ──────────────────────────────────────────────────────
  info "installing system utilities..."
  run_cmd sudo pacman -S --needed --noconfirm \
    power-profiles-daemon fwupd openssh wireguard-tools openresolv rsync
  [[ $DRY_RUN -eq 0 ]] && ok "system utilities"

  # ── Virtualization ────────────────────────────────────────────────────────
  info "installing virt-manager and dependencies..."
  run_cmd sudo pacman -S --needed --noconfirm \
    libvirt virt-manager qemu-full dnsmasq edk2-ovmf swtpm
  [[ $DRY_RUN -eq 0 ]] && ok "virt-manager + libvirt + QEMU"

  # ── System services ───────────────────────────────────────────────────────
  info "enabling system services..."

  if [[ $DRY_RUN -eq 1 ]]; then
    info "would enable: docker.service, power-profiles-daemon.service, apparmor.service, libvirtd.service"
    info "would add $USER to docker and libvirt groups"
  else
    # Docker
    if systemctl is-enabled --quiet docker.service 2>/dev/null; then
      skip "docker.service (already enabled)"
    else
      sudo systemctl enable --now docker.service
      ok "docker.service enabled"
    fi

    if groups "$USER" | grep -qw docker; then
      skip "docker group (already a member)"
    else
      sudo usermod -aG docker "$USER"
      warn "added $USER to docker group — log out and back in for this to take effect"
      _add_warning "log out and back in for docker group membership to take effect"
    fi

    # Power profiles daemon
    if systemctl is-enabled --quiet power-profiles-daemon.service 2>/dev/null; then
      skip "power-profiles-daemon.service (already enabled)"
    else
      sudo systemctl enable --now power-profiles-daemon.service
      ok "power-profiles-daemon.service enabled"
    fi

    # AppArmor
    if systemctl is-enabled --quiet apparmor.service 2>/dev/null; then
      skip "apparmor.service (already enabled)"
    else
      sudo systemctl enable apparmor.service
      ok "apparmor.service enabled"
    fi

    # Libvirt
    if systemctl is-enabled --quiet libvirtd.service 2>/dev/null; then
      skip "libvirtd.service (already enabled)"
    else
      sudo systemctl enable --now libvirtd.service
      sudo systemctl enable --now virtlogd.service
      ok "libvirtd.service enabled"
    fi

    if groups "$USER" | grep -qw libvirt; then
      skip "libvirt group (already a member)"
    else
      sudo usermod -aG libvirt "$USER"
      warn "added $USER to libvirt group — log out and back in for this to take effect"
      _add_warning "log out and back in for libvirt group membership to take effect"
    fi
  fi
fi

# =============================================================================
# 2. SYMLINKS
# =============================================================================

section "Symlinking Dotfiles"

info "~/.local/bin (scripts)"
link_tree "$DOTFILES_HOME/.local/bin" "$HOME/.local/bin"

if [[ -d "$DOTFILES_HOME/.local/lib" ]]; then
  info "~/.local/lib (libraries)"
  link_tree "$DOTFILES_HOME/.local/lib" "$HOME/.local/lib"
fi

if [[ -d "$DOTFILES_HOME/.local/share" ]]; then
  info "~/.local/share"
  link_tree "$DOTFILES_HOME/.local/share" "$HOME/.local/share"

  # Submodule directories are linked as whole units so their .git stays intact
  while IFS= read -r submod; do
    local_share_prefix="root/home/.local/share/"
    if [[ "$submod" == "$local_share_prefix"* ]]; then
      rel="${submod#root/home/}"
      link_dir "$REPO_ROOT/$submod" "$HOME/$rel"
    fi
  done < <(_submodule_paths)
fi

info "~/.config"
link_tree "$DOTFILES_HOME/.config" "$HOME/.config"

info "\$HOME dotfiles (.gitconfig, .vimrc, .ssh/config, …)"
while IFS= read -r src; do
  rel="${src#"$DOTFILES_HOME/"}"
  dest="$HOME/$rel"
  if _resolve_conflict "$dest" "$src"; then
    if [[ $DRY_RUN -eq 1 ]]; then
      echo -e "  ${DIM}+ ln -s $src $dest${NC}"
    else
      mkdir -p "$(dirname "$dest")"
      ln -s "$src" "$dest"
    fi
  fi
done < <(find "$DOTFILES_HOME" -type f \
  ! -path "$DOTFILES_HOME/.config/*" \
  ! -path "$DOTFILES_HOME/.local/*")

# =============================================================================
# 3. PERMISSIONS
# =============================================================================

section "Permissions"

# Secure SSH and GPG directories
if [[ -d "$HOME/.ssh" ]]; then
  run_cmd chmod 700 "$HOME/.ssh"
  [[ $DRY_RUN -eq 0 ]] && ok "~/.ssh → 700"
fi
if [[ -d "$HOME/.gnupg" ]]; then
  run_cmd chmod 700 "$HOME/.gnupg"
  [[ $DRY_RUN -eq 0 ]] && ok "~/.gnupg → 700"
fi

# /etc/hosts
if [[ -f "$DOTFILES_ROOT_ETC/hosts" ]]; then
  HOSTS_SRC="$DOTFILES_ROOT_ETC/hosts"
  HOSTS_DEST="/etc/hosts"

  if [[ -f "$HOSTS_DEST" ]] && cmp -s "$HOSTS_SRC" "$HOSTS_DEST"; then
    skip "/etc/hosts (already up to date)"
  elif [[ $MERGE -eq 1 ]] && [[ -f "$HOSTS_DEST" ]]; then
    merge_into_src "$HOSTS_DEST" "$HOSTS_SRC"
    run_cmd sudo cp "$HOSTS_SRC" "$HOSTS_DEST"
    run_cmd sudo chown root:root "$HOSTS_DEST"
    run_cmd sudo chmod 644 "$HOSTS_DEST"
    [[ $DRY_RUN -eq 0 ]] && ok "/etc/hosts deployed (merged)"
  elif [[ $BACKUP -eq 1 ]] && [[ -f "$HOSTS_DEST" ]]; then
    hosts_bak="${HOSTS_DEST}.bak.$(date +%s)"
    info "backing up /etc/hosts → $hosts_bak"
    run_cmd sudo cp "$HOSTS_DEST" "$hosts_bak"
    run_cmd sudo cp "$HOSTS_SRC" "$HOSTS_DEST"
    run_cmd sudo chown root:root "$HOSTS_DEST"
    run_cmd sudo chmod 644 "$HOSTS_DEST"
    [[ $DRY_RUN -eq 0 ]] && ok "/etc/hosts deployed"
  elif [[ $FORCE -eq 1 ]] || [[ ! -f "$HOSTS_DEST" ]]; then
    run_cmd sudo cp "$HOSTS_SRC" "$HOSTS_DEST"
    run_cmd sudo chown root:root "$HOSTS_DEST"
    run_cmd sudo chmod 644 "$HOSTS_DEST"
    [[ $DRY_RUN -eq 0 ]] && ok "/etc/hosts deployed"
  else
    fail "/etc/hosts conflict — use --merge, --backup, or --force"
    _add_error "conflict: /etc/hosts already exists"
  fi
fi

# Power profile udev rule
UDEV_SRC="$DOTFILES_ROOT_ETC/udev/rules.d/99-power-profile.rules"
UDEV_DEST="/etc/udev/rules.d/99-power-profile.rules"
if [[ -f "$UDEV_SRC" ]]; then
  if [[ -f "$UDEV_DEST" ]] && cmp -s "$UDEV_SRC" "$UDEV_DEST"; then
    skip "power profile udev rule (already up to date)"
  elif [[ $DRY_RUN -eq 1 ]]; then
    info "would install udev rule → $UDEV_DEST"
  else
    if sudo cp "$UDEV_SRC" "$UDEV_DEST"; then
      sudo udevadm control --reload-rules
      sudo udevadm trigger --subsystem-match=power_supply
      ok "power profile udev rule installed"
    else
      warn "failed to install udev rule — skipping"
      _add_warning "udev rule install failed: $UDEV_DEST"
    fi
  fi
fi

# Libvirt environment variable
LIBVIRT_PROFILE_SRC="$DOTFILES_ROOT_ETC/profile.d/libvirt.sh"
LIBVIRT_PROFILE_DEST="/etc/profile.d/libvirt.sh"
if [[ -f "$LIBVIRT_PROFILE_SRC" ]]; then
  if [[ -f "$LIBVIRT_PROFILE_DEST" ]] && cmp -s "$LIBVIRT_PROFILE_SRC" "$LIBVIRT_PROFILE_DEST"; then
    skip "libvirt profile.d script (already up to date)"
  elif [[ $DRY_RUN -eq 1 ]]; then
    info "would install libvirt profile.d script → $LIBVIRT_PROFILE_DEST"
  else
    if sudo cp "$LIBVIRT_PROFILE_SRC" "$LIBVIRT_PROFILE_DEST"; then
      sudo chmod 644 "$LIBVIRT_PROFILE_DEST"
      ok "libvirt profile.d script installed"
    else
      warn "failed to install libvirt profile.d script — skipping"
      _add_warning "libvirt profile.d script install failed: $LIBVIRT_PROFILE_DEST"
    fi
  fi
fi

# AppArmor kernel parameters (Limine bootloader)
LIMINE_CONFIG="/etc/default/limine"
APPARMOR_PARAM="lsm=landlock,lockdown,yama,integrity,apparmor,bpf"
if [[ -f "$LIMINE_CONFIG" ]]; then
  if grep -q "${APPARMOR_PARAM}" "$LIMINE_CONFIG"; then
    skip "AppArmor kernel parameters (already configured)"
  elif [[ $DRY_RUN -eq 1 ]]; then
    info "would add AppArmor LSM params to $LIMINE_CONFIG"
  else
    info "adding AppArmor LSM params to Limine config..."
    if sudo sed -i \
      "/KERNEL_CMDLINE\[default\]+=\"quiet splash\"/a KERNEL_CMDLINE[default]+=\" ${APPARMOR_PARAM}\"" \
      "$LIMINE_CONFIG"; then
      sudo limine-mkinitcpio
      ok "AppArmor kernel parameters configured"
      warn "reboot required for AppArmor to become active"
      _add_warning "reboot required for AppArmor kernel parameters to take effect"
    else
      warn "failed to configure AppArmor kernel parameters"
      _add_warning "AppArmor kernel parameter configuration failed"
    fi
  fi
else
  skip "AppArmor kernel params ($LIMINE_CONFIG not found — add manually: $APPARMOR_PARAM)"
fi

# =============================================================================
# 4. LIBVIRT NETWORK & FIREWALL
# =============================================================================

section "Libvirt Network Configuration"

# Configure libvirt default network with proper DNS
LIBVIRT_NETWORK_XML="$DOTFILES_ROOT_ETC/libvirt/networks/default.xml"
if [[ -f "$LIBVIRT_NETWORK_XML" ]]; then
  if [[ $DRY_RUN -eq 1 ]]; then
    info "would configure libvirt default network with DNS forwarders"
  else
    # Check if network exists
    if sudo virsh net-info default &>/dev/null; then
      skip "libvirt default network (already configured)"
    else
      info "configuring libvirt default network..."
      sudo virsh net-define "$LIBVIRT_NETWORK_XML"
      sudo virsh net-autostart default
      sudo virsh net-start default
      ok "libvirt default network configured"
    fi
  fi
fi

# Configure UFW rules for libvirt
if command -v ufw &>/dev/null; then
  if [[ $DRY_RUN -eq 1 ]]; then
    info "would configure UFW rules for libvirt (virbr0)"
  else
    info "configuring UFW firewall rules for libvirt..."
    
    # Allow traffic on virbr0 interface
    if ! sudo ufw status | grep -q "Anywhere on virbr0"; then
      sudo ufw allow in on virbr0 comment 'libvirt bridge'
      sudo ufw allow out on virbr0
      ok "UFW: allowed traffic on virbr0"
    else
      skip "UFW: virbr0 rules already configured"
    fi
    
    # Allow DNS to libvirt bridge
    if ! sudo ufw status | grep -q "192.168.122.1 53"; then
      sudo ufw allow in on virbr0 to 192.168.122.1 port 53 comment 'libvirt DNS'
      ok "UFW: allowed DNS on virbr0"
    else
      skip "UFW: DNS rule already configured"
    fi
    
    # Allow routing from virbr0 to internet (detect primary interface)
    PRIMARY_IFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
    if [[ -n "$PRIMARY_IFACE" ]]; then
      if ! sudo ufw status | grep -q "virbr0.*$PRIMARY_IFACE"; then
        sudo ufw route allow in on virbr0 out on "$PRIMARY_IFACE" comment 'libvirt NAT'
        ok "UFW: allowed routing virbr0 → $PRIMARY_IFACE"
      else
        skip "UFW: routing rule already configured"
      fi
    else
      warn "could not detect primary network interface — add UFW route rule manually:"
      echo -e "    ${DIM}sudo ufw route allow in on virbr0 out on <interface>${NC}"
      _add_warning "UFW routing rule not added — primary interface not detected"
    fi
  fi
else
  skip "UFW not installed — libvirt firewall rules skipped"
fi

# =============================================================================
# 5. SYSTEMD USER SERVICES
# =============================================================================

section "Systemd User Services"

if [[ $DRY_RUN -eq 0 ]]; then
  systemctl --user daemon-reload
fi

enable_user_service "ssh-agent.service"
enable_user_service "power-profile-switch.service"
enable_user_service "battery-notify.timer"

# =============================================================================
# 5. VPN (optional)
# =============================================================================

section "VPN Setup"

if [[ $WITH_VPN -eq 0 ]]; then
  skip "VPN setup skipped (use --with-vpn to enable)"
else
  VPN_CONF_NAME="debbie-local"
  VPN_CONF_DEST="/etc/wireguard/${VPN_CONF_NAME}.conf"
  VPN_CONF_SEARCH=(
    "$HOME/Downloads/debbie.conf"
    "$REPO_ROOT/debbie.conf"
  )

  if [[ -f "$VPN_CONF_DEST" ]]; then
    skip "VPN config already at $VPN_CONF_DEST"
  else
    VPN_CONF=""
    for candidate in "${VPN_CONF_SEARCH[@]}"; do
      if [[ -f "$candidate" ]]; then
        VPN_CONF="$candidate"
        break
      fi
    done

    if [[ -z "$VPN_CONF" ]]; then
      warn "debbie.conf not found (checked: ${VPN_CONF_SEARCH[*]})"
      warn "place it in ~/Downloads and re-run with --with-vpn"
      _add_warning "VPN config not found — place debbie.conf in ~/Downloads and re-run"
    elif [[ $DRY_RUN -eq 1 ]]; then
      info "would install: $VPN_CONF → $VPN_CONF_DEST"
    else
      info "found: $VPN_CONF"
      sudo install -o root -g root -m 600 "$VPN_CONF" "$VPN_CONF_DEST"
      ok "VPN '$VPN_CONF_NAME' installed"
      info "connect with:     vpn up home"
      info "autoconnect with: vpn autoconnect home"
    fi
  fi
fi

# =============================================================================
# 6. NAS SYNC (optional)
# =============================================================================

section "NAS Sync"

if [[ $WITH_NAS_SYNC -eq 0 ]]; then
  skip "NAS sync skipped (use --with-nas-sync to enable)"
else
  run_cmd mkdir -p "$HOME/.config/nas-sync"

  PASSWORD_FILE="$HOME/.config/nas-sync/rsync-password"
  if [[ -f "$PASSWORD_FILE" ]]; then
    skip "rsync password file already exists"
  elif [[ $DRY_RUN -eq 1 ]]; then
    info "would prompt for NAS rsync password"
  else
    echo ""
    echo -e "  ${BOLD}NAS rsync password${NC} (press Enter to skip):"
    read -r -s -p "  Password: " nas_password
    echo ""
    if [[ -n "$nas_password" ]]; then
      printf '%s' "$nas_password" > "$PASSWORD_FILE"
      chmod 600 "$PASSWORD_FILE"
      ok "password file created: $PASSWORD_FILE"
    else
      warn "skipped password setup — create it later:"
      echo -e "    ${DIM}printf 'your_password' > $PASSWORD_FILE && chmod 600 $PASSWORD_FILE${NC}"
    fi
  fi

  # Initial clone from NAS (ordered list — associative arrays have undefined iteration order)
  NAS_MODULES=(
    "documents:Documents"
    "music:Music"
    "photos:Photos"
    "audiobooks:Audiobooks"
    "books:Books"
  )

  if [[ $DRY_RUN -eq 1 ]]; then
    info "would check NAS connectivity and clone:"
    for entry in "${NAS_MODULES[@]}"; do
      local_dir="${entry##*:}"
      info "  ~/$local_dir"
    done
  else
    info "checking NAS connectivity..."
    if "$HOME/.local/lib/check-nas-connection" 2>/dev/null; then
      ok "NAS reachable — starting initial clone"
      for entry in "${NAS_MODULES[@]}"; do
        module="${entry%%:*}"
        local_dir="${entry##*:}"
        mkdir -p "$HOME/$local_dir"
        info "syncing $module → ~/$local_dir..."
        if rsync -az --password-file="$PASSWORD_FILE" \
          "rsync://nate@nas.lan:873/$module/" "$HOME/$local_dir/" 2>/dev/null; then
          ok "$module synced"
        else
          warn "failed to sync $module — continuing"
          _add_warning "NAS initial sync failed for: $module"
        fi
      done
    else
      warn "NAS not reachable — skipping initial clone"
      warn "timers will sync automatically once NAS is accessible"
      _add_warning "NAS not reachable during install — initial clone skipped"
    fi
  fi

  # Enable NAS sync timers
  info "enabling NAS sync timers..."
  for entry in "${NAS_MODULES[@]}"; do
    module="${entry%%:*}"
    enable_user_service "nas-sync-${module}.timer"
  done
fi

# =============================================================================
# SUMMARY
# =============================================================================

echo ""
echo -e "${BOLD}${CYAN}══════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}  Summary${NC}"
echo -e "${BOLD}${CYAN}══════════════════════════════════════════${NC}"

if [[ $DRY_RUN -eq 1 ]]; then
  echo -e "\n  ${YELLOW}Dry run complete — no changes were made${NC}"
fi

if [[ ${#WARNINGS[@]} -gt 0 ]]; then
  echo ""
  echo -e "  ${YELLOW}Warnings (${#WARNINGS[@]}):${NC}"
  for w in "${WARNINGS[@]}"; do
    warn "$w"
  done
fi

if [[ ${#ERRORS[@]} -gt 0 ]]; then
  echo ""
  echo -e "  ${RED}Errors (${#ERRORS[@]}):${NC}"
  for e in "${ERRORS[@]}"; do
    fail "$e"
  done
  echo ""
  echo -e "  ${RED}Install completed with errors — see above.${NC}"
  exit 1
else
  echo ""
  echo -e "  ${GREEN}✓ Install complete!${NC}"
fi
echo ""
