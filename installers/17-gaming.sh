# 17-gaming.sh — Steam + Vulkan drivers

section "Gaming"

info "installing Steam and gaming dependencies..."
run_cmd sudo pacman -S --needed --noconfirm \
  steam vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader
[[ $DRY_RUN -eq 0 ]] && ok "Steam + Vulkan drivers (Intel)"