# 01-core.sh — base system packages

section "Core Packages"

info "installing core packages..."
run_cmd sudo pacman -S --needed --noconfirm \
  base base-devel git curl wget linux-headers linux-firmware intel-ucode
[[ $DRY_RUN -eq 0 ]] && ok "core packages"