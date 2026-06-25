# 000510-steam.sh — Steam + Vulkan drivers (Intel)
# Installs: steam vulkan-intel lib32-vulkan-intel vulkan-icd-loader
#           lib32-vulkan-icd-loader
# Links:    —
# Enables:  —
# Note: Enables the [multilib] repo in /etc/pacman.conf (required for steam +
#       lib32 packages) before installing.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "steam"

# Enable multilib repo if commented out
if grep -q '^#\[multilib\]' /etc/pacman.conf; then
  info "enabling multilib repository in /etc/pacman.conf..."
  sudo sed -i '/^#\[multilib\]/,/^#Include/{s/^#//}' /etc/pacman.conf
  sudo pacman -Sy --noconfirm
  ok "multilib repository enabled"
else
  skip "multilib repository (already enabled)"
fi

install_pacman \
  steam vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader
ok "Steam + Vulkan drivers (Intel)"
