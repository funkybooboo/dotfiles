#!/usr/bin/env bash
# install.sh — install packages, symlink dotfiles, enable services
#
# Order of operations:
#   0. Preflight    (distro check, not-root, internet)
#   1. Installers    (run scripts in installers/ — packages + system setup)
#   2. Symlinks      (bins, libs, share, configs, dotfiles)
#   3. Permissions   (.ssh, .gnupg)
#   4. /etc files    (hosts, udev rules, libvirt profile, security configs)
#   5. systemd       (daemon-reload, enable user + custom system services)
#   6. Late setup    (secretmgr bootstrap, NAS initial sync)

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
  echo -e "  --help,     -h  Show this help message"
  echo ""
  echo -e "${BOLD}Common invocations:${NC}"
  echo -e "  $0 --dry-run           ${DIM}# preview without changes${NC}"
  echo -e "  $0 --backup            ${DIM}# fresh install (recommended)${NC}"
  echo -e "  $0 --restore --dry-run ${DIM}# preview restore${NC}"
  echo -e "  $0 --restore           ${DIM}# undo installation${NC}"
  exit 0
}

while [[ $# -gt 0 ]]; do
  case $1 in
  -n | --dry-run)  DRY_RUN=1;  shift ;;
  -f | --force)    FORCE=1;    shift ;;
  -b | --backup)   BACKUP=1;   shift ;;
  -m | --merge)    MERGE=1;    shift ;;
  -r | --restore)  RESTORE=1;  shift ;;
  -h | --help)     usage ;;
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
  if [[ $conflict_flags -gt 0 ]]; then
    echo -e "${RED}✗ --restore cannot be combined with --backup, --merge, or --force.${NC}"
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

# Retry a command up to N times with a delay between attempts.
# Usage: run_cmd_retry <retries> <delay_secs> <cmd> [args...]
run_cmd_retry() {
  local retries="$1"; shift
  local delay="$1"; shift
  local attempt=1
  while [[ $attempt -le $retries ]]; do
    if [[ $DRY_RUN -eq 1 ]]; then
      echo -e "  ${DIM}+ $*${NC}"
      return 0
    fi
    if "$@"; then
      return 0
    fi
    if [[ $attempt -lt $retries ]]; then
      warn "attempt $attempt/$retries failed for: $* — retrying in ${delay}s"
      sleep "$delay"
    fi
    attempt=$((attempt + 1))
  done
  return 1
}

# Install one or more packages via pacman. Skips already-installed ones (pacman
# --needed handles this). Fails the script if pacman itself fails.
# Usage: install_pacman pkg1 pkg2 ...
install_pacman() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo -e "  ${DIM}+ sudo pacman -S --needed --noconfirm $*${NC}"
    return 0
  fi
  sudo pacman -S --needed --noconfirm "$@"
}

# Install AUR packages one at a time via yay. Each package is checked first —
# if already installed it is skipped. Build/ssl failures on one package do NOT
# abort the install; they are recorded as warnings instead.
# Usage: install_aur pkg1 pkg2 ...
install_aur() {
  local pkg failures=0
  for pkg in "$@"; do
    if pacman -Q "$pkg" &>/dev/null; then
      skip "$pkg (already installed)"
      continue
    fi
    if [[ $DRY_RUN -eq 1 ]]; then
      echo -e "  ${DIM}+ yay -S --needed --noconfirm $pkg${NC}"
      continue
    fi
    if ! run_cmd_retry 3 30 yay -S --needed --noconfirm "$pkg"; then
      warn "$pkg failed to install"
      _add_warning "AUR package failed to install: $pkg"
      failures=$((failures + 1))
    else
      ok "$pkg"
    fi
  done
  return $failures
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

# _resolve_conflict <dest> <src>
#   Handles an existing file/symlink at dest before linking src → dest.
#   Returns 0 to proceed with linking, 1 to skip (already correct or error).
_resolve_conflict() {
  local dest="$1"
  local src="$2"

  # Handle existing symlink
  if [[ -L "$dest" ]]; then
    local current_target
    current_target=$(readlink "$dest")
    if [[ "$current_target" == "$src" ]]; then
      # Already correctly symlinked — idempotent, skip silently
      return 1
    else
      # Wrong target — remove it
      if [[ $DRY_RUN -eq 0 ]]; then
        rm -f "$dest"
      else
        echo -e "  ${DIM}+ rm $dest (wrong target)${NC}"
      fi
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
    if [[ $DRY_RUN -eq 1 ]]; then
      warn "conflict: '${dest/$HOME/\~}' already exists (content differs)"
      if [[ -f "$dest" ]] && [[ -f "$src" ]]; then
        info "Differences:"
        diff -u "$dest" "$src" 2>/dev/null | head -20 | while IFS= read -r line; do
          echo -e "    ${DIM}$line${NC}"
        done || true
      fi
      _add_warning "conflict: '$dest' — use --backup, --merge, or --force"
    else
      fail "conflict: '${dest/$HOME/\~}' already exists"
      _add_error "conflict: '$dest' — use --backup, --merge, or --force"
    fi
    return 1
  fi
}

# link_tree <src_root> <dest_root> [exclude_dirs...]
#   Symlinks individual files from src_root into dest_root, preserving
#   directory structure. Specified dirs are excluded (use link_dir for those instead).
link_tree() {
  local src_root="$1"
  local dest_root="$2"
  shift 2
  local exclude_dirs=("$@")

  local find_args=(find "$src_root" -type f)

  # Exclude specified directories
  for dir in "${exclude_dirs[@]}"; do
    find_args+=(-not -path "$src_root/$dir/*")
  done

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
#   Symlinks an entire directory as a single unit so internal structure
#   stays intact.
link_dir() {
  local src="$1"
  local dest="$2"

  if [[ $DRY_RUN -eq 1 ]]; then
    info "would link dir: ${dest/$HOME/\~} → $src"
    return
  fi

  # Check if already correctly symlinked
  if [[ -L "$dest" ]]; then
    local current_target
    current_target=$(readlink "$dest")
    if [[ "$current_target" == "$src" ]]; then
      return
    else
      # Wrong symlink - remove it
      rm -f "$dest"
    fi
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
  done < <(find "$DOTFILES_HOME" -type f) || true
  
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

# Internet check
if ping -c1 -W2 archlinux.org &>/dev/null; then
  ok "internet connectivity"
else
  fail "no internet connection — required for package installation"
  exit 1
fi

if [[ $DRY_RUN -eq 1 ]]; then
  echo ""
  echo -e "  ${YELLOW}DRY RUN — no changes will be made${NC}"
fi

# =============================================================================
# 1. INSTALLERS
# =============================================================================

section "Package Installation & System Setup"

for _installer in "$REPO_ROOT"/installers/[0-9]*.sh; do
  if [[ -f "$_installer" ]]; then
    source "$_installer"
  else
    warn "no installers found in $REPO_ROOT/installers/"
    break
  fi
done
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
