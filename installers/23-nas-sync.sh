# 23-nas-sync.sh — NAS sync config dir + password setup

section "NAS Sync"

# Create NAS sync config directory
run_cmd mkdir -p "$HOME/.config/nas-sync"

# NAS rsync password setup
PASSWORD_FILE="$HOME/.config/nas-sync/rsync-password"
if [[ -f "$PASSWORD_FILE" ]]; then
  skip "rsync password file already exists"
elif command -v pass-cli &>/dev/null && pass-cli info &>/dev/null; then
  # Try Proton Pass first (pass-cli is available from installer 22,
  # but secretmgr won't be in PATH yet since symlinks haven't been created)
  NAS_PASS=$(pass-cli item view --vault-name NAS --item-title rsync --field password 2>/dev/null) || true
  if [[ -n "$NAS_PASS" ]]; then
    if [[ $DRY_RUN -eq 1 ]]; then
      info "would set NAS password from Proton Pass"
    else
      printf '%s' "$NAS_PASS" > "$PASSWORD_FILE"
      chmod 600 "$PASSWORD_FILE"
      ok "NAS password set from Proton Pass"
    fi
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

# Initial NAS clone is deferred to install.sh (needs symlinked helper scripts)
# NAS sync timer enable is deferred to install.sh (needs symlinked unit files)