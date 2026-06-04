# 05-intrusion-detection.sh — rkhunter, chkrootkit, auditd

section "Intrusion Detection"

info "installing intrusion detection tools..."
run_cmd sudo pacman -S --needed --noconfirm rkhunter audit
run_cmd yay -S --needed --noconfirm chkrootkit
[[ $DRY_RUN -eq 0 ]] && ok "rkhunter + chkrootkit + auditd"

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