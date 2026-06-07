# 20-vpn.sh — Proton VPN + GlobalProtect

section "VPN Clients"

info "installing Proton VPN CLI..."
install_aur proton-vpn-cli
[[ $DRY_RUN -eq 0 ]] && ok "proton-vpn-cli" || true

info "installing Proton VPN (GUI)..."
install_aur proton-vpn-gtk-app
[[ $DRY_RUN -eq 0 ]] && ok "proton-vpn-gtk-app" || true

info "installing GlobalProtect OpenConnect..."
install_aur globalprotect-openconnect-git
[[ $DRY_RUN -eq 0 ]] && ok "globalprotect-openconnect-git" || true