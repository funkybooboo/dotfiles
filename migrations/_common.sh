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
# conflict, or moved to nix) doesn't abort the migration run under 'set -e'.
#
# Resilience: a single bad target in a multi-package `pacman -S` aborts the
# ENTIRE transaction (none of the other packages install). To avoid that, we
# pre-filter the requested packages against the sync repos with `pacman -Si`,
# install the available ones in one transaction, and warn explicitly about any
# that are not in a pacman repo (those are usually nix packages or renamed
# packages that belong in install_nix instead).
#
# Failures are recorded via _add_warning and surface in the final summary.
# Usage: install_pacman pkg1 pkg2 ...
install_pacman() {
  local pkg available=() missing=()
  for pkg in "$@"; do
    if pacman -Si "$pkg" >/dev/null 2>&1; then
      available+=("$pkg")
    else
      missing+=("$pkg")
    fi
  done

  if (( ${#missing[@]} > 0 )); then
    warn "not in pacman repos (skipping — likely nix or renamed): ${missing[*]}"
    _add_warning "pacman packages not in repos (install via nix or manually): ${missing[*]}"
  fi

  if (( ${#available[@]} > 0 )); then
    if ! sudo pacman -S --needed --noconfirm "${available[@]}"; then
      warn "pacman install failed for one or more packages: ${available[*]}"
      _add_warning "pacman install failed for: ${available[*]}"
    fi
  fi
}

# -----------------------------------------------------------------------------
# Install a Flatpak app from the flathub remote. Idempotent + non-fatal.
# Requires the flathub remote (provisioned by 000301-flatpak.sh).
# Usage: install_flatpak <app-id>
install_flatpak() {
  local app="$1"
  if flatpak list --columns=application 2>/dev/null | grep -qx "$app"; then
    skip "flatpak $app (installed)"
    return 0
  fi
  if flatpak install -y --noninteractive flathub "$app"; then
    ok "flatpak: $app"
  else
    warn "flatpak install failed: $app"
    _add_warning "flatpak install failed: $app"
  fi
}

# Remove a Flatpak app idempotently (non-fatal). Skips if not installed.
# Used when an app moves off flatpak to a pacman/nix package so the
# flatpak copy doesn't ghost the replacement .desktop / binary. `--delete-data`
# drops the app's per-user data too (the new package keeps none of it by design).
# Usage: remove_flatpak <app-id>
remove_flatpak() {
  local app="$1"
  if ! flatpak list --columns=application 2>/dev/null | grep -qx "$app"; then
    skip "flatpak $app (not installed)"
    return 0
  fi
  info "removing flatpak: $app"
  if flatpak uninstall -y --noninteractive --delete-data "$app" 2>/dev/null; then
    ok "removed flatpak: $app"
  else
    warn "failed to remove flatpak $app"
    _add_warning "failed to remove flatpak: $app"
  fi
}

# -----------------------------------------------------------------------------
# Install a package from our local flake (~/dotfiles/flake.nix) via
# `nix profile add`. Idempotent + non-fatal. This is the TIER 2 install
# source (after pacman). The flake wraps nixpkgs with allowUnfree = true
# and pins the nixpkgs revision via flake.lock — so `nix profile add .#<pkg>`
# works for both free and unfree packages without --impure or env vars.
# No sudo needed — nix installs into the user's profile (~/.nix-profile/).
# Usage: install_nix <flake-attribute>   e.g. install_nix .#calcure
install_nix() {
  local attr="$1"
  local pkgname="${attr#.#}"
  # Check if already installed — match the exact flake attribute line in
  # `nix profile list` to avoid false positives from substring matches.
  # The flake attribute appears as "packages.x86_64-linux.<pkgname>" for
  # our local flake. We capture to a temp file first because `nix profile
  # list` is non-deterministic under pipefail (intermittently returns
  # partial/empty output when piped directly).
  local _nix_list_tmp
  _nix_list_tmp=$(mktemp)
  nix profile list >"$_nix_list_tmp" 2>/dev/null || true
  if command -v nix &>/dev/null && \
     grep -q "packages\.x86_64-linux\.$pkgname" "$_nix_list_tmp"; then
    rm -f "$_nix_list_tmp"
    skip "nix $pkgname (installed)"
    return 0
  fi
  rm -f "$_nix_list_tmp"
  if ! command -v nix &>/dev/null; then
    warn "nix not found — run the nix migration (000011) first"
    _add_warning "nix not installed; cannot install $pkgname"
    return 0
  fi
  info "installing $pkgname from flake"
  if nix profile add "$attr" 2>/dev/null; then
    ok "nix: $pkgname"
  else
    warn "nix profile add failed for $pkgname"
    _add_warning "nix install failed: $pkgname"
  fi
}

# -----------------------------------------------------------------------------
# Remove one or more packages idempotently (non-fatal). Used to drop superseded
# packages after their nix/pacman replacement is
# in place. Uses plain -R (leaves shared deps as orphans; a later `pacman -Qdt`
# cleanup can sweep them) and falls back to -Rdd if a dep check blocks removal.
# Usage: remove_pkg <pkg1> [pkg2 ...]
remove_pkg() {
  local pkg
  for pkg in "$@"; do
    if ! pacman -Q "$pkg" &>/dev/null; then
      skip "$pkg (not installed)"
      continue
    fi
    info "removing superseded package: $pkg"
    if sudo pacman -R --noconfirm "$pkg" 2>/dev/null; then
      ok "removed: $pkg"
    elif sudo pacman -Rdd --noconfirm "$pkg" 2>/dev/null; then
      ok "removed (--nodeps): $pkg"
    else
      warn "failed to remove $pkg"
      _add_warning "failed to remove: $pkg"
    fi
  done
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
# Note: Starts the unit immediately (--now). Only use this for services that
#       cannot disrupt the running session. For services that would (e.g.
#       greetd grabbing the active TTY, ufw dropping an SSH session), use
#       enable_system_service_no_start instead — the unit starts on next boot.
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

# Enable a systemd SYSTEM service idempotently (sudo) WITHOUT starting it now.
# Use for services that would disrupt the running session if started
# immediately (greetd takes over the active VT; ufw applies default-deny and
# can drop an SSH session). The unit is enabled and will start on next boot.
# Usage: enable_system_service_no_start "foo.service"
enable_system_service_no_start() {
  local unit="$1"
  sudo systemctl daemon-reload 2>/dev/null || true
  if sudo systemctl is-enabled --quiet "$unit" 2>/dev/null; then
    skip "$unit (already enabled — starts on next boot)"
  else
    if sudo systemctl enable "$unit" 2>/dev/null; then
      ok "enabled (no start): $unit — starts on next boot"
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

  # sudo is a hard prerequisite: it is used from the very first migration
  # (000001-system-update). It is intentionally NOT installed by a migration —
  # on a truly fresh Arch install `base`/`base-devel` do not include it, so we
  # fail here with a clear instruction instead of dying mid-run later.
  if command -v sudo &>/dev/null; then
    ok "sudo available"
  else
    fail "sudo is not installed — migrations use it from the first step."
    fail "install it first:  pacman -S sudo"
    exit 1
  fi

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

  # ---------------------------------------------------------------------------
  # Initialize git submodules (sources/*). A plain `git clone` of the dotfiles
  # repo does NOT populate submodule working trees, so several migrations that
  # build from source (000108 99-plugin, 000305 lazymusic, 000540 lazycsv,
  # 000552 HandBrake) would find empty directories. This --init --recursive
  # is a fast no-op when submodules are already checked out at the recorded
  # SHA; --depth 1 limits the cost for the large HandBrake history. Non-fatal:
  # a failure is recorded as a warning so the rest of the run continues and
  # the affected migration reports its own missing-source warning.
  # ---------------------------------------------------------------------------
  if [[ -f "$REPO_ROOT/.gitmodules" ]]; then
    if git -C "$REPO_ROOT" submodule update --init --recursive --depth 1 2>/dev/null; then
      _submods=$(git -C "$REPO_ROOT" config -f "$REPO_ROOT/.gitmodules" --name-only --get-regexp 'path' 2>/dev/null | wc -l)
      ok "git submodules initialized (${_submods} source tree(s): sources/*)"
    else
      warn "git submodule init failed — building from source may be skipped"
      _add_warning "git submodule init failed; some sources/* migrations may skip their build"
    fi
  else
    skip "git submodules (no .gitmodules present)"
  fi

  # ---------------------------------------------------------------------------
  # Disk encryption checks (enforced). Silent encryption-setup failure is
  # otherwise undetectable: archinstall can pull in cryptsetup and write a
  # crypttab template yet never actually create the LUKS container, leaving an
  # unencrypted system that boots with no passphrase prompt. Three independent
  # signals are checked — all must pass on a properly encrypted install. See
  # the README "Fresh install (archinstall)" section for the setup that
  # satisfies these.
  #
  # Override with DOTFILES_ALLOW_UNENCRYPTED=1 to skip (for intentionally
  # unencrypted systems — discouraged for a laptop).
  # ---------------------------------------------------------------------------
  if [[ "${DOTFILES_ALLOW_UNENCRYPTED:-0}" == "1" ]]; then
    warn "DOTFILES_ALLOW_UNENCRYPTED=1 — skipping disk encryption checks"
    _add_warning "running without disk encryption (DOTFILES_ALLOW_UNENCRYPTED=1)"
  else
    _enc_fail=0

    # 1. Kernel cmdline must reference cryptdevice= (tells the initramfs to
    #    unlock a LUKS device for root). /proc/cmdline is world-readable.
    if grep -q 'cryptdevice=' /proc/cmdline 2>/dev/null; then
      ok "kernel cmdline has cryptdevice= (encrypted root)"
    else
      fail "no cryptdevice= in /proc/cmdline — root is not configured for LUKS"
      _enc_fail=1
    fi

    # 2. A LUKS container must physically exist (lsblk reports crypto_LUKS).
    if lsblk -o FSTYPE -n 2>/dev/null | grep -q 'crypto_LUKS'; then
      ok "LUKS container detected by lsblk"
    else
      fail "no crypto_LUKS device found by lsblk — disk is not encrypted"
      _enc_fail=1
    fi

    # 3. mkinitcpio must carry the encrypt hook (initramfs can prompt + unlock).
    if grep -E '^HOOKS=' /etc/mkinitcpio.conf 2>/dev/null | grep -qw 'encrypt'; then
      ok "mkinitcpio has encrypt hook"
    else
      fail "mkinitcpio.conf HOOKS lacks 'encrypt' — initramfs cannot unlock LUKS"
      _enc_fail=1
    fi

    if (( _enc_fail != 0 )); then
      echo ""
      fail "disk encryption checks FAILED — the root filesystem is not encrypted."
      fail "See the README 'Fresh install (archinstall)' section for the setup,"
      fail "or, if you intentionally run without encryption, re-run with:"
      fail "  DOTFILES_ALLOW_UNENCRYPTED=1 ./migrate.sh"
      exit 1
    fi
  fi
}

print_summary() {
  local mode="${1:-migrate}"
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
    if [[ "$mode" == "secrets" ]]; then
      echo -e "  ${RED}Secrets setup completed with errors — see above.${NC}"
    else
      echo -e "  ${RED}Migrations completed with errors — see above.${NC}"
    fi
    exit 1
  fi

  echo ""
  if [[ "$mode" == "secrets" ]]; then
    echo -e "  ${GREEN}✓ Secrets & sync setup complete!${NC}"
  else
    echo -e "  ${GREEN}✓ Migrations complete!${NC}"
    echo -e "  ${DIM}Next: reboot into Hyprland, then run ./setup.sh${NC}"
  fi
  echo ""
}
