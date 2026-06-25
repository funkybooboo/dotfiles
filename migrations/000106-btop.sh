# 000106-btop.sh — btop system monitor
# Installs: btop
# Links:    ~/.config/btop/**
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "btop"

install_pacman btop
link_tree "$DOTFILES_HOME/.config/btop" "$HOME/.config/btop"
