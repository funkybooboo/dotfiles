# 000311-waybar.sh — Waybar status bar
# Installs: waybar
# Links:    ~/.config/waybar/**
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "waybar"

install_pacman waybar
link_tree "$DOTFILES_HOME/.config/waybar" "$HOME/.config/waybar"
