#!/usr/bin/env bash
# setup-secrets.sh — interactive secret & sync setup
#
# Run this AFTER ./migrate.sh has completed AND you have rebooted into your
# Hyprland desktop (it needs a browser for logins and network for the NAS).
#
# What it does:
#   1. Proton Pass (pass-cli) login — opens a browser
#   2. NAS rsync password — pulled from Proton Pass, or prompted
#   3. secretmgr bootstrap — injects secrets into templated configs
#   4. NAS initial clone — documents, music, photos, audiobooks, books
#
# This script is intentionally separate from the migrations: migrations are
# non-interactive and run in any environment (including a fresh TTY). This
# script is interactive and requires a desktop + network.

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
REPO_ROOT="$PWD"

# shellcheck source=migrations/_common.sh
source "$REPO_ROOT/migrations/_common.sh"

section "Secrets & Sync Setup"

# =============================================================================
# 1. Proton Pass login
# =============================================================================

if command -v pass-cli &>/dev/null; then
  if pass-cli info &>/dev/null 2>&1; then
    skip "Proton Pass (already logged in)"
  else
    info "Proton Pass login required — opening browser for authentication..."
    echo -e "  ${DIM}Complete login in the browser, then return here.${NC}"
    pass-cli login
    ok "Proton Pass logged in"
  fi
else
  fail "pass-cli not found — run the proton-pass migration first"
  _add_error "pass-cli not installed"
fi

# =============================================================================
# 2. Tailscale authentication
# =============================================================================

if command -v tailscale &>/dev/null; then
  if tailscale status &>/dev/null; then
    skip "Tailscale (already authenticated and connected)"
  else
    info "Tailscale login required — opening browser for authentication..."
    echo -e "  ${DIM}After completing login in the browser, press Enter to continue.${NC}"
    sudo tailscale up --accept-routes
    ok "Tailscale connected"
  fi
else
  warn "tailscale not found — run the tailscale migration first"
  _add_warning "tailscale not installed; run it manually after"
fi

# =============================================================================
# 3. NAS rsync password
# =============================================================================

PASSWORD_FILE="$HOME/.config/nas-sync/rsync-password"
mkdir -p "$(dirname "$PASSWORD_FILE")"

if [[ -f "$PASSWORD_FILE" ]]; then
  skip "NAS rsync password file already exists"
else
  NAS_PASS=""
  if command -v pass-cli &>/dev/null && pass-cli info &>/dev/null 2>&1; then
    NAS_PASS=$(pass-cli item view --vault-name NAS --item-title rsync --field password 2>/dev/null || true)
  fi

  if [[ -n "$NAS_PASS" ]]; then
    printf '%s' "$NAS_PASS" > "$PASSWORD_FILE"
    chmod 600 "$PASSWORD_FILE"
    ok "NAS password set from Proton Pass"
  else
    echo ""
    echo -e "  ${BOLD}NAS rsync password${NC} (press Enter to skip):"
    read -r -s -p "  Password: " nas_password
    echo ""
    if [[ -n "$nas_password" ]]; then
      printf '%s' "$nas_password" > "$PASSWORD_FILE"
      chmod 600 "$PASSWORD_FILE"
      ok "NAS password file created: $PASSWORD_FILE"
    else
      warn "skipped password setup — create it later:"
      echo -e "    ${DIM}printf 'your_password' > $PASSWORD_FILE && chmod 600 $PASSWORD_FILE${NC}"
      _add_warning "NAS rsync password not set"
    fi
  fi
fi

# =============================================================================
# 4. secretmgr bootstrap
# =============================================================================

_SECRETMGR="$HOME/.local/bin/secretmgr"
if [[ -x "$_SECRETMGR" ]]; then
  info "Bootstrapping secrets with secretmgr..."
  "$_SECRETMGR" bootstrap
  ok "Secrets bootstrapped"
else
  warn "secretmgr not found at $_SECRETMGR — run the secretmgr migration first"
  _add_warning "secretmgr not found; run '$_SECRETMGR bootstrap' manually"
fi

# =============================================================================
# 5. NAS initial clone
# =============================================================================

NAS_MODULES=(
  "documents:Documents"
  "music:Music"
  "photos:Photos"
  "audiobooks:Audiobooks"
  "books:Books"
)
NAS_RSYNC_BASE="rsync://funkybooboo@tnas:873/public/funkybooboo"

if [[ ! -f "$PASSWORD_FILE" ]]; then
  warn "no NAS password file — skipping initial clone"
  _add_warning "NAS initial clone skipped (no password)"
else
  info "checking NAS connectivity..."
  if "$HOME/.local/lib/check-nas-connection" 2>/dev/null; then
    ok "NAS reachable — checking for initial clone"
    for entry in "${NAS_MODULES[@]}"; do
      module="${entry%%:*}"
      local_dir="${entry##*:}"
      if [[ -d "$HOME/$local_dir" ]] && [[ -n "$(ls -A "$HOME/$local_dir" 2>/dev/null)" ]]; then
        skip "$module (already synced to ~/$local_dir)"
      else
        mkdir -p "$HOME/$local_dir"
        info "syncing $module → ~/$local_dir..."
        if rsync -az --password-file="$PASSWORD_FILE" \
          "$NAS_RSYNC_BASE/$module/" "$HOME/$local_dir/" 2>/dev/null; then
          ok "$module synced"
        else
          warn "failed to sync $module — continuing"
          _add_warning "NAS initial sync failed for: $module"
        fi
      fi
    done
  else
    warn "NAS not reachable — timers will sync automatically once it is accessible"
    _add_warning "NAS not reachable — initial clone skipped"
  fi
fi

# =============================================================================
# 6. Enable NAS sync timers (in case the nas-sync migration couldn't reach NAS)
# =============================================================================

info "ensuring NAS sync timers are enabled..."
for entry in "${NAS_MODULES[@]}"; do
  module="${entry%%:*}"
  enable_user_service "nas-sync-${module}.timer"
done

print_summary
