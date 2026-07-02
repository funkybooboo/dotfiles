# 000510-steam.sh -- Steam + Vulkan drivers (Intel)
# Installs: steam vulkan-intel lib32-vulkan-intel vulkan-icd-loader
#           lib32-vulkan-icd-loader
# Links:    --
# Enables:  --
# Note: Enables the [multilib] repo in /etc/pacman.conf (required for steam +
#       lib32 packages) before installing.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "steam"

if is_debian; then
  # Enable 32-bit architecture for Steam on Debian/Ubuntu
  info "adding i386 architecture for Steam..."
  if sudo dpkg --add-architecture i386; then
    ok "i386 architecture enabled"
  else
    warn "dpkg --add-architecture i386 failed (may already be enabled)"
  fi
  install_apt steam-installer mesa-vulkan-drivers
else
  # Enable multilib repo if commented out (Arch only -- pacman.conf is Arch-specific)
  if grep -q '^#\[multilib\]' /etc/pacman.conf; then
    info "enabling multilib repository in /etc/pacman.conf..."
    if sudo sed -i '/^#\[multilib\]/,/^#Include/{s/^#//}' /etc/pacman.conf && \
       sudo pacman -Sy --noconfirm; then
      ok "multilib repository enabled"
    else
      warn "failed to enable multilib -- steam/lib32 packages may not install"
      _add_warning "multilib repo enable failed; steam + lib32 packages may fail"
    fi
  else
    skip "multilib repository (already enabled)"
  fi

  install_pacman \
    steam vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader
fi
ok "Steam + Vulkan drivers (Intel)"
