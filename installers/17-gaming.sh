# 17-gaming.sh — Steam + Vulkan drivers

section "Gaming"

# Enable multilib repo (required for steam and lib32 packages)
if grep -q '^#\[multilib\]' /etc/pacman.conf; then
  if [[ $DRY_RUN -eq 1 ]]; then
    info "would enable multilib repository in /etc/pacman.conf"
  else
    sudo sed -i '/^#\[multilib\]/,/^#Include/{s/^#//}' /etc/pacman.conf
    sudo pacman -Sy --noconfirm
    ok "multilib repository enabled"
  fi
else
  skip "multilib repository (already enabled)"
fi

info "installing Steam and gaming dependencies..."
install_pacman \
  steam vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader
[[ $DRY_RUN -eq 0 ]] && ok "Steam + Vulkan drivers (Intel)" || true