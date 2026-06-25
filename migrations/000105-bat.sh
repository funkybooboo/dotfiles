# 000105-bat.sh — bat (cat clone with syntax highlighting)
# Installs: bat
# Links:    ~/.config/bat/config
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "bat"

install_pacman bat
link_file "$DOTFILES_HOME/.config/bat/config" "$HOME/.config/bat/config"
