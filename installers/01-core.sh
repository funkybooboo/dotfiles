# 01-core.sh — base system packages

section "Core Packages"

info "installing core packages..."
install_pacman \
  base base-devel git curl wget linux-headers linux-firmware intel-ucode
[[ $DRY_RUN -eq 0 ]] && ok "core packages" || true