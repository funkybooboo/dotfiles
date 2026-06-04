# 04-application-security.sh — USBGuard + OpenSnitch

section "Application Security"

info "installing application security tools..."
run_cmd sudo pacman -S --needed --noconfirm \
  usbguard opensnitch
run_cmd yay -S --needed --noconfirm \
  usbguard-qt
[[ $DRY_RUN -eq 0 ]] && ok "usbguard + opensnitch"

# USBGuard service + initial policy
if [[ $DRY_RUN -eq 1 ]]; then
  info "would enable: usbguard.service"
  info "would configure USBGuard IPC + generate initial policy"
else
  # Enable USBGuard
  if systemctl is-enabled --quiet usbguard.service 2>/dev/null; then
    skip "usbguard.service (already enabled)"
  else
    sudo systemctl enable --now usbguard.service
    ok "usbguard.service enabled"
  fi

  # IPC allowed users
  if grep -q "IPCAllowedUsers=root $USER" /etc/usbguard/usbguard-daemon.conf 2>/dev/null; then
    skip "usbguard IPC (already configured)"
  else
    sudo sed -i "s/IPCAllowedUsers=root/IPCAllowedUsers=root $USER/" \
      /etc/usbguard/usbguard-daemon.conf
    ok "usbguard IPC configured"
  fi

  # Initial policy
  if [[ -s /etc/usbguard/rules.conf ]]; then
    skip "usbguard policy (already exists)"
  else
    sudo usbguard generate-policy | sudo tee /etc/usbguard/rules.conf > /dev/null
    ok "usbguard policy generated"
  fi
fi

# OpenSnitch service
if [[ $DRY_RUN -eq 1 ]]; then
  info "would enable: opensnitchd.service"
else
  if systemctl is-enabled --quiet opensnitchd.service 2>/dev/null; then
    skip "opensnitchd.service (already enabled)"
  else
    sudo systemctl enable --now opensnitchd.service
    ok "opensnitchd.service enabled"
  fi
fi