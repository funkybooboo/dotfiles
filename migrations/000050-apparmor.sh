# 000050-apparmor.sh — AppArmor + profiles + kernel LSM parameters
# Installs: apparmor apparmor.d
# Links:    —
# Enables:  apparmor.service
# Depends: 000020-bootloader (Limine must be installed so LSM params can be
#           added to /etc/default/limine)

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "AppArmor"

install_pacman apparmor
install_aur apparmor.d
ok "AppArmor + profiles"

enable_system_service "apparmor.service"

# Add AppArmor LSM parameters to Limine config
APPARMOR_PARAM="lsm=landlock,lockdown,yama,integrity,apparmor,bpf"
LIMINE_CONFIG="/etc/default/limine"

if [[ -f "$LIMINE_CONFIG" ]]; then
  if grep -q "$APPARMOR_PARAM" "$LIMINE_CONFIG"; then
    skip "AppArmor kernel parameters (already configured)"
  else
    info "adding AppArmor LSM params to Limine config..."
    sudo sed -i \
      "/KERNEL_CMDLINE\[default\]+=\"quiet splash\"/a KERNEL_CMDLINE[default]+=\" ${APPARMOR_PARAM}\"" \
      "$LIMINE_CONFIG"
    sudo limine-mkinitcpio
    ok "AppArmor kernel parameters configured"
    warn "reboot required for AppArmor to become active"
    _add_warning "reboot required for AppArmor kernel parameters to take effect"
  fi
else
  warn "$LIMINE_CONFIG not found — run 000020-bootloader first"
  _add_warning "could not configure AppArmor kernel params (limine config missing)"
fi
