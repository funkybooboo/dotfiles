# 12-browsers.sh — web browsers

section "Browsers"

info "installing browsers..."
run_cmd sudo pacman -S --needed --noconfirm firefox chromium
run_cmd yay -S --needed --noconfirm librewolf-bin brave-bin
[[ $DRY_RUN -eq 0 ]] && ok "browsers"