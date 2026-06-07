# 30-late-setup.sh — secretmgr bootstrap and NAS initial sync

section "Secrets & Sync"

# secretmgr bootstrap (needs symlinked configs in place)
_SECRETMGR="$HOME/.local/bin/secretmgr"
if [[ -x "$_SECRETMGR" ]]; then
  info "Bootstrapping secrets with secretmgr..."
  "$_SECRETMGR" bootstrap
  ok "Secrets bootstrapped"
  # Restart openviking now that API keys have been injected
  if systemctl --user is-active --quiet openviking.service 2>/dev/null; then
    systemctl --user restart openviking.service 2>/dev/null && ok "openviking restarted with secrets"
  fi
else
  warn "secretmgr not found at $_SECRETMGR — skipping secret bootstrap"
  _add_warning "secretmgr not found; run '$_SECRETMGR bootstrap' manually after login"
fi

# NAS initial sync (needs symlinked helper scripts in PATH)
NAS_MODULES=(
  "documents:Documents"
  "music:Music"
  "photos:Photos"
  "audiobooks:Audiobooks"
  "books:Books"
)

NAS_RSYNC_BASE="rsync://funkybooboo@tnas:873/public/funkybooboo"

PASSWORD_FILE="$HOME/.config/nas-sync/rsync-password"

if [[ $DRY_RUN -eq 1 ]]; then
  info "would check NAS connectivity and clone:"
  for entry in "${NAS_MODULES[@]}"; do
    local_dir="${entry##*:}"
    info "  ~/$local_dir"
  done
else
  info "checking NAS connectivity..."
  if "$HOME/.local/lib/check-nas-connection" 2>/dev/null; then
    ok "NAS reachable — checking for initial clone"
    for entry in "${NAS_MODULES[@]}"; do
      module="${entry%%:*}"
      local_dir="${entry##*:}"
      
      # Skip if directory exists and has content (already synced)
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