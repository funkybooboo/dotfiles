#!/usr/bin/env bash
# _common.sh — shared helpers and globals for migrations
#
# Sourced once by migrate.sh before running migrations. Each migration also
# guard-sources this file so it can be executed standalone:
#
#   [[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
#
# Conflict policy: backup-only. A conflicting real file at a link target is
# moved to <dest>.bak.N before symlinking. There are no --force/--merge/--dry
# modes and no restore mode.

set -euo pipefail

# =============================================================================
# PATHS (computed from this file's location so standalone runs work)
# =============================================================================

if [[ -z "${_COMMON_LOADED:-}" ]]; then
  _COMMON_LOADED=1
fi

MIGRATIONS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$MIGRATIONS_DIR/.." && pwd)"
DOTFILES_ROOT="$REPO_ROOT/root"
DOTFILES_ROOT_ETC="$DOTFILES_ROOT/etc"
DOTFILES_HOME="$DOTFILES_ROOT/home"

# =============================================================================
# COLORS & OUTPUT
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

# Summary tracking — collected and printed once at the end by migrate.sh
WARNINGS=()
ERRORS=()
_add_warning() { WARNINGS+=("$1"); }
_add_error()   { ERRORS+=("$1"); }

# =============================================================================
# COMMAND HELPERS
# =============================================================================

# Run a command. Kept as a thin wrapper so migrations read clearly and so a
# single choke point exists if behaviour ever needs to change.
run_cmd() {
  "$@"
}

# Retry a command up to N times with a delay between attempts.
# Usage: run_cmd_retry <retries> <delay_secs> <cmd> [args...]
run_cmd_retry() {
  local retries="$1"; shift
  local delay="$1"; shift
  local attempt=1
  while [[ $attempt -le $retries ]]; do
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

# =============================================================================
# PACKAGE INSTALL HELPERS
# =============================================================================

# Install pacman packages idempotently (--needed skips already-installed).
# Always returns 0 so a single pacman failure (package renamed, removed,
# conflict) doesn't abort the migration run under 'set -e'. Failures are
# recorded via _add_warning and surface in the final summary.
# Usage: install_pacman pkg1 pkg2 ...
install_pacman() {
  if ! sudo pacman -S --needed --noconfirm "$@"; then
    warn "pacman install failed for one or more packages: $*"
    _add_warning "pacman install failed for: $*"
  fi
}

# Install AUR packages one at a time via yay. Already-installed packages are
# skipped; a build failure on one package is recorded as a warning, not fatal.
# Usage: install_aur pkg1 pkg2 ...
# Note: Always returns 0 so a single AUR failure doesn't abort the migration
#       run under 'set -e'. Failures are recorded via _add_warning and surface
#       in the final summary.
install_aur() {
  local pkg failures=0
  for pkg in "$@"; do
    if pacman -Q "$pkg" &>/dev/null; then
      skip "$pkg (already installed)"
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
  return 0
}

# =============================================================================
# SYSTEMD HELPERS
# =============================================================================

# Enable a systemd USER service idempotently. Runs daemon-reload first so newly
# linked unit files are picked up. Starts the unit if not already active.
# Usage: enable_user_service "foo.service"
enable_user_service() {
  local unit="$1"
  local unit_file="$HOME/.config/systemd/user/$unit"
  if [[ ! -f "$unit_file" ]]; then
    skip "$unit (unit file not found)"
    return
  fi
  systemctl --user daemon-reload 2>/dev/null || true
  if systemctl --user is-enabled --quiet "$unit" 2>/dev/null; then
    systemctl --user start "$unit" 2>/dev/null || true
    skip "$unit (already enabled)"
  else
    if systemctl --user enable --now "$unit" 2>/dev/null; then
      ok "enabled: $unit"
    else
      warn "failed to enable $unit"
      _add_warning "systemd user unit failed to enable: $unit"
    fi
  fi
}

# Enable a systemd SYSTEM service idempotently (sudo). Runs daemon-reload first.
# Usage: enable_system_service "foo.service"
enable_system_service() {
  local unit="$1"
  sudo systemctl daemon-reload 2>/dev/null || true
  if sudo systemctl is-enabled --quiet "$unit" 2>/dev/null; then
    sudo systemctl start "$unit" 2>/dev/null || true
    skip "$unit (already enabled)"
  else
    if sudo systemctl enable --now "$unit" 2>/dev/null; then
      ok "enabled: $unit"
    else
      warn "failed to enable $unit"
      _add_warning "systemd system unit failed to enable: $unit"
    fi
  fi
}

# =============================================================================
# SYMLINK HELPERS (HOME tree)
# =============================================================================

# _resolve_conflict <dest> <src>
#   Backup-only conflict resolution before linking src -> dest.
#   Returns 0 to proceed with linking, 1 to skip (already correct).
_resolve_conflict() {
  local dest="$1"
  local src="$2"

  # Already a symlink?
  if [[ -L "$dest" ]]; then
    if [[ "$(readlink "$dest")" == "$src" ]]; then
      return 1  # already correctly linked
    fi
    rm -f "$dest"  # wrong target — replace
  fi

  # Nothing at dest — proceed
  [[ -e "$dest" ]] || [[ -L "$dest" ]] || return 0

  # Real file with identical content — silently replace with symlink
  if [[ -f "$dest" ]] && [[ ! -L "$dest" ]] && cmp -s "$src" "$dest"; then
    info "replacing identical file with symlink: ${dest/$HOME/\~}"
    rm -f "$dest"
    return 0
  fi

  # Conflict — back up the existing file, then proceed
  local backup_dest="${dest}.bak"
  local counter=1
  while [[ -e "$backup_dest" ]]; do
    backup_dest="${dest}.bak.${counter}"
    counter=$((counter + 1))
  done
  info "backing up: ${dest/$HOME/\~} → ${backup_dest/$HOME/\~}"
  mv "$dest" "$backup_dest"
  return 0
}

# link_file <src> <dest>
#   Symlink a single file into the HOME tree with backup-on-conflict.
link_file() {
  local src="$1"
  local dest="$2"
  if _resolve_conflict "$dest" "$src"; then
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
  fi
}

# link_tree <src_root> <dest_root> [exclude_dirs...]
#   Symlink individual files from src_root into dest_root, preserving structure.
link_tree() {
  local src_root="$1"
  local dest_root="$2"
  shift 2
  local exclude_dirs=("$@")
  local find_args=(find "$src_root" -type f)
  for dir in "${exclude_dirs[@]}"; do
    find_args+=(-not -path "$src_root/$dir/*")
  done
  mkdir -p "$dest_root"
  while IFS= read -r src; do
    local rel="${src#"${src_root}/"}"
    link_file "$src" "$dest_root/$rel"
  done < <("${find_args[@]}")
}

# link_dir <src> <dest>
#   Symlink an entire directory as a single unit.
link_dir() {
  local src="$1"
  local dest="$2"
  if [[ -L "$dest" ]]; then
    if [[ "$(readlink "$dest")" == "$src" ]]; then
      return
    fi
    rm -f "$dest"
  fi
  if [[ -e "$dest" ]] || [[ -L "$dest" ]]; then
    local bak="${dest}.bak.$(date +%s)"
    info "backing up: ${dest/$HOME/\~} → ${bak/$HOME/\~}"
    mv "$dest" "$bak"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
  ok "linked dir: ${dest/$HOME/\~}"
}

# =============================================================================
# /etc DEPLOY HELPER
# =============================================================================

# deploy_etc_file <src> <dest> [mode]
#   Idempotently copy a file into /etc with sudo. If dest exists and differs,
#   back it up to <dest>.bak.<timestamp> first. Sets root:root and the given mode
#   (default 644). Skips silently when already up to date.
deploy_etc_file() {
  local src="$1"
  local dest="$2"
  local mode="${3:-644}"

  if [[ ! -f "$src" ]]; then
    warn "source missing, skipping: $src"
    return
  fi

  if [[ -f "$dest" ]] && sudo cmp -s "$src" "$dest" 2>/dev/null; then
    skip "$dest (already up to date)"
    return
  fi

  if [[ -f "$dest" ]]; then
    local bak="${dest}.bak.$(date +%s)"
    info "backing up $dest → $bak"
    sudo cp "$dest" "$bak"
  fi

  sudo mkdir -p "$(dirname "$dest")"
  sudo cp "$src" "$dest"
  sudo chown root:root "$dest"
  sudo chmod "$mode" "$dest"
  ok "deployed: $dest"
}

# =============================================================================
# PREFLIGHT & SUMMARY (called by migrate.sh)
# =============================================================================

preflight() {
  section "Preflight Checks"

  if [[ $EUID -eq 0 ]]; then
    fail "Do not run as root. Run as your normal user (sudo is called internally)."
    exit 1
  fi
  ok "not running as root"

  if [[ -f /etc/os-release ]]; then
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

  if ping -c1 -W2 archlinux.org &>/dev/null; then
    ok "internet connectivity"
  else
    fail "no internet connection — required for package installation"
    exit 1
  fi
}

print_summary() {
  echo ""
  echo -e "${BOLD}${CYAN}══════════════════════════════════════════${NC}"
  echo -e "${BOLD}${CYAN}  Summary${NC}"
  echo -e "${BOLD}${CYAN}══════════════════════════════════════════${NC}"

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
    echo -e "  ${RED}Migrations completed with errors — see above.${NC}"
    exit 1
  fi

  echo ""
  echo -e "  ${GREEN}✓ Migrations complete!${NC}"
  echo -e "  ${DIM}Next: reboot into Hyprland, then run ./setup-secrets.sh${NC}"
  echo ""
}
