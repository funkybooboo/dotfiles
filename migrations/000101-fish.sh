# 000101-fish.sh — fish shell + config + functions
# Installs: fish
# Links:    ~/.config/fish/**
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "fish"

install_pacman fish
link_tree "$DOTFILES_HOME/.config/fish" "$HOME/.config/fish"
