# 20-vpn.sh — Proton VPN + GlobalProtect

section "VPN Clients"

info "installing Proton VPN CLI..."
run_cmd yay -S --needed --noconfirm proton-vpn-cli
[[ $DRY_RUN -eq 0 ]] && ok "proton-vpn-cli"

info "installing Proton VPN (GUI)..."
run_cmd yay -S --needed --noconfirm proton-vpn-gtk-app
[[ $DRY_RUN -eq 0 ]] && ok "proton-vpn-gtk-app"

info "installing GlobalProtect OpenConnect..."
run_cmd yay -S --needed --noconfirm globalprotect-openconnect-git
[[ $DRY_RUN -eq 0 ]] && ok "globalprotect-openconnect-git"