# 12-browsers.sh — web browsers

section "Browsers"

info "installing browsers..."
install_pacman firefox chromium
install_aur librewolf-bin brave-bin
[[ $DRY_RUN -eq 0 ]] && ok "browsers" || true