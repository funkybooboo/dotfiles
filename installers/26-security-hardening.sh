# 26-security-hardening.sh — deploy security configs and enable scanners

section "Security Hardening"

# rkhunter config
RKHUNTER_SRC="$DOTFILES_ROOT_ETC/rkhunter.conf"
RKHUNTER_DEST="/etc/rkhunter.conf"
if [[ -f "$RKHUNTER_SRC" ]]; then
  if [[ -f "$RKHUNTER_DEST" ]]; then
    if cmp -s "$RKHUNTER_SRC" "$RKHUNTER_DEST" 2>/dev/null || sudo sh -c "cmp -s '$RKHUNTER_SRC' '$RKHUNTER_DEST'" 2>/dev/null; then
      skip "rkhunter.conf (already up to date)"
    elif [[ $DRY_RUN -eq 1 ]]; then
      warn "conflict: '$RKHUNTER_DEST' already exists (content differs)"
      info "Differences:"
      sudo diff -u "$RKHUNTER_DEST" "$RKHUNTER_SRC" 2>/dev/null | head -20 | while IFS= read -r line; do
        echo -e "    ${DIM}$line${NC}"
      done || true
      _add_warning "conflict: '$RKHUNTER_DEST' — use --backup, --merge, or --force"
    else
      sudo cp "$RKHUNTER_SRC" "$RKHUNTER_DEST"
      sudo chown root:root "$RKHUNTER_DEST"
      sudo chmod 640 "$RKHUNTER_DEST"
      ok "rkhunter.conf deployed"
    fi
  else
    if [[ $DRY_RUN -eq 1 ]]; then
      info "would install: rkhunter.conf"
    else
      sudo cp "$RKHUNTER_SRC" "$RKHUNTER_DEST"
      sudo chown root:root "$RKHUNTER_DEST"
      sudo chmod 640 "$RKHUNTER_DEST"
      ok "rkhunter.conf deployed"
    fi
  fi
fi

# auditd rules
AUDIT_SRC="$DOTFILES_ROOT_ETC/audit/rules.d/hardening.rules"
AUDIT_DEST="/etc/audit/rules.d/hardening.rules"
if [[ -f "$AUDIT_SRC" ]]; then
  if [[ -f "$AUDIT_DEST" ]] && cmp -s "$AUDIT_SRC" "$AUDIT_DEST"; then
    skip "audit rules (already up to date)"
  elif [[ $DRY_RUN -eq 1 ]]; then
    warn "conflict: '$AUDIT_DEST' already exists (content differs)"
    info "Differences:"
    diff -u "$AUDIT_DEST" "$AUDIT_SRC" 2>/dev/null | head -20 | while IFS= read -r line; do
      echo -e "    ${DIM}$line${NC}"
    done || true
    _add_warning "conflict: '$AUDIT_DEST' — use --backup, --merge, or --force"
  else
    sudo mkdir -p /etc/audit/rules.d
    sudo cp "$AUDIT_SRC" "$AUDIT_DEST"
    sudo chown root:root "$AUDIT_DEST"
    sudo chmod 640 "$AUDIT_DEST"
    sudo augenrules --load
    ok "audit rules deployed and loaded"
  fi
fi

# rkhunter + chkrootkit systemd units
for unit in rkhunter-scan.service rkhunter-scan.timer chkrootkit-scan.service chkrootkit-scan.timer; do
  UNIT_SRC="$DOTFILES_ROOT_ETC/systemd/system/$unit"
  UNIT_DEST="/etc/systemd/system/$unit"
  if [[ -f "$UNIT_SRC" ]]; then
    if [[ -f "$UNIT_DEST" ]] && cmp -s "$UNIT_SRC" "$UNIT_DEST"; then
      skip "$unit (already up to date)"
    elif [[ $DRY_RUN -eq 1 ]]; then
      warn "conflict: '$UNIT_DEST' already exists (content differs)"
      info "Differences:"
      diff -u "$UNIT_DEST" "$UNIT_SRC" 2>/dev/null | head -20 | while IFS= read -r line; do
        echo -e "    ${DIM}$line${NC}"
      done || true
      _add_warning "conflict: '$UNIT_DEST' — use --backup, --merge, or --force"
    else
      sudo cp "$UNIT_SRC" "$UNIT_DEST"
      sudo chown root:root "$UNIT_DEST"
      sudo chmod 644 "$UNIT_DEST"
      ok "$unit deployed"
    fi
  fi
done

# pacman hook
HOOK_SRC="$DOTFILES_ROOT_ETC/pacman.d/hooks/rkhunter-propupd.hook"
HOOK_DEST="/etc/pacman.d/hooks/rkhunter-propupd.hook"
if [[ -f "$HOOK_SRC" ]]; then
  if [[ -f "$HOOK_DEST" ]] && cmp -s "$HOOK_SRC" "$HOOK_DEST"; then
    skip "rkhunter pacman hook (already up to date)"
  elif [[ $DRY_RUN -eq 1 ]]; then
    warn "conflict: '$HOOK_DEST' already exists (content differs)"
    info "Differences:"
    diff -u "$HOOK_DEST" "$HOOK_SRC" 2>/dev/null | head -20 | while IFS= read -r line; do
      echo -e "    ${DIM}$line${NC}"
    done || true
    _add_warning "conflict: '$HOOK_DEST' — use --backup, --merge, or --force"
  else
    sudo mkdir -p /etc/pacman.d/hooks
    sudo cp "$HOOK_SRC" "$HOOK_DEST"
    sudo chown root:root "$HOOK_DEST"
    sudo chmod 644 "$HOOK_DEST"
    ok "rkhunter pacman hook deployed"
  fi
fi

# rkhunter baseline
if [[ $DRY_RUN -eq 1 ]]; then
  info "would initialize rkhunter file properties database"
elif command -v rkhunter &>/dev/null; then
  if [[ ! -f /var/lib/rkhunter/db/rkhunter.dat ]]; then
    info "initializing rkhunter file properties database..."
    sudo rkhunter --propupd 2>/dev/null
    ok "rkhunter database initialized"
  else
    skip "rkhunter database (already exists)"
  fi
fi

# Enable rkhunter + chkrootkit timers
for timer in rkhunter-scan.timer chkrootkit-scan.timer; do
  if systemctl is-enabled --quiet "$timer" 2>/dev/null; then
    skip "$timer (already enabled)"
  else
    if [[ $DRY_RUN -eq 1 ]]; then
      info "would enable: $timer"
    else
      sudo systemctl enable --now "$timer"
      ok "$timer enabled"
    fi
  fi
done