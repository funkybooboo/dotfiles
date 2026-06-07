# 16-system-utilities.sh — earlyoom, power, fwupd, UFW, etc.

section "System Utilities"

info "installing system utilities..."
install_pacman \
  earlyoom \
  power-profiles-daemon fwupd openssh openresolv yazi \
  snapper plymouth ufw brightnessctl bluez bluez-utils \
  cups cups-pdf system-config-printer thunar \
  btrfs-progs dosfstools exfatprogs efibootmgr \
  iwd wireless-regdb bind xdg-user-dirs \
  greetd sof-firmware sudo
install_aur limine limine-mkinitcpio-hook \
  zram-generator ufw-docker greetd-tuigreet
install_aur limine-snapper-sync
[[ $DRY_RUN -eq 0 ]] && ok "system utilities" || true

# Enable system services
if [[ $DRY_RUN -eq 1 ]]; then
  info "would enable: power-profiles-daemon.service, earlyoom.service, greetd.service"
else
  # Power profiles daemon
  if systemctl is-enabled --quiet power-profiles-daemon.service 2>/dev/null; then
    skip "power-profiles-daemon.service (already enabled)"
  else
    sudo systemctl enable --now power-profiles-daemon.service
    ok "power-profiles-daemon.service enabled"
  fi

  # earlyoom
  if systemctl is-enabled --quiet earlyoom.service 2>/dev/null; then
    skip "earlyoom.service (already enabled)"
  else
    sudo systemctl enable --now earlyoom.service
    ok "earlyoom.service enabled"
  fi

  # greetd (display manager)
  if systemctl is-enabled --quiet greetd.service 2>/dev/null; then
    skip "greetd.service (already enabled)"
  else
    sudo systemctl enable --now greetd.service
    ok "greetd.service enabled"
  fi
fi

# Disable and mask cups-browsed (attack surface, CVE-2024-47176)
if [[ $DRY_RUN -eq 1 ]]; then
  info "would disable + mask: cups-browsed.service"
else
  if systemctl is-masked --quiet cups-browsed.service 2>/dev/null; then
    skip "cups-browsed.service (already masked)"
  else
    sudo systemctl disable --now cups-browsed.service 2>/dev/null || true
    sudo systemctl mask cups-browsed.service
    ok "cups-browsed.service disabled and masked"
  fi
fi