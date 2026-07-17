# 000520-proton-vpn.sh — Proton VPN CLI + GUI + vpn wrapper script
# Installs: proton-vpn-cli proton-vpn-gtk-app (both in extra/ — official Arch)
# Links:    ~/.local/bin/vpn
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "proton vpn"

install_pacman proton-vpn-cli proton-vpn-gtk-app
link_file "$DOTFILES_HOME/.local/bin/vpn" "$HOME/.local/bin/vpn"
