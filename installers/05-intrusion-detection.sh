# 05-intrusion-detection.sh — rkhunter, chkrootkit, auditd

section "Intrusion Detection"

info "installing intrusion detection tools..."
install_pacman rkhunter audit
install_aur chkrootkit
[[ $DRY_RUN -eq 0 ]] && ok "rkhunter + chkrootkit + auditd" || true

# Enable auditd service
if [[ $DRY_RUN -eq 1 ]]; then
  info "would enable: auditd.service"
else
  if systemctl is-enabled --quiet auditd.service 2>/dev/null; then
    skip "auditd.service (already enabled)"
  else
    sudo systemctl enable --now auditd.service
    ok "auditd.service enabled"
  fi
fi

# rkhunter + chkrootkit timers are enabled in install.sh (after /etc/ unit files are deployed)