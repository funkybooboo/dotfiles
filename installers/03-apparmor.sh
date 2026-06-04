# 03-apparmor.sh — AppArmor + kernel LSM parameters

section "AppArmor"

info "installing AppArmor..."
run_cmd sudo pacman -S --needed --noconfirm apparmor
run_cmd yay -S --needed --noconfirm apparmor.d
[[ $DRY_RUN -eq 0 ]] && ok "AppArmor + 2000+ profiles"

# Enable AppArmor service
if [[ $DRY_RUN -eq 1 ]]; then
  info "would enable: apparmor.service"
else
  if systemctl is-enabled --quiet apparmor.service 2>/dev/null; then
    skip "apparmor.service (already enabled)"
  else
    sudo systemctl enable apparmor.service
    ok "apparmor.service enabled"
  fi
fi

# Add AppArmor LSM parameters to Limine config
APPARMOR_PARAM="lsm=landlock,lockdown,yama,integrity,apparmor,bpf"
LIMINE_CONFIG="/etc/default/limine"
if [[ -f "$LIMINE_CONFIG" ]]; then
  if grep -q "${APPARMOR_PARAM}" "$LIMINE_CONFIG"; then
    skip "AppArmor kernel parameters (already configured)"
  elif [[ $DRY_RUN -eq 1 ]]; then
    info "would add AppArmor LSM params to $LIMINE_CONFIG"
  else
    info "adding AppArmor LSM params to Limine config..."
    if sudo sed -i \
      "/KERNEL_CMDLINE\[default\]+=\"quiet splash\"/a KERNEL_CMDLINE[default]+=\" ${APPARMOR_PARAM}\"" \
      "$LIMINE_CONFIG"; then
      sudo limine-mkinitcpio
      ok "AppArmor kernel parameters configured"
      warn "reboot required for AppArmor to become active"
      _add_warning "reboot required for AppArmor kernel parameters to take effect"
    else
      warn "failed to configure AppArmor kernel parameters"
      _add_warning "AppArmor kernel parameter configuration failed"
    fi
  fi
else
  skip "AppArmor kernel params ($LIMINE_CONFIG not found — add manually: $APPARMOR_PARAM)"
fi