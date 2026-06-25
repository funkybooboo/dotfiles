# 000104-tmux.sh — tmux terminal multiplexer
# Installs: tmux
# Links:    ~/.config/tmux/tmux.conf
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "tmux"

install_pacman tmux
link_file "$DOTFILES_HOME/.config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
