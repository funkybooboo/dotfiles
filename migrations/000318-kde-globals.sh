# 000318-kde-globals.sh — KDE global settings (Breeze Dark look)
# Installs: —
# Links:    ~/.config/kdeglobals
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "kde globals"

link_file "$DOTFILES_HOME/.config/kdeglobals" "$HOME/.config/kdeglobals"
