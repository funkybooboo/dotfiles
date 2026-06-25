# 000302-ghostty.sh — Ghostty terminal emulator
# Installs: ghostty
# Links:    ~/.config/ghostty/config
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "ghostty"

install_aur ghostty
link_file "$DOTFILES_HOME/.config/ghostty/config" "$HOME/.config/ghostty/config"
