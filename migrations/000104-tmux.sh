# 000104-tmux.sh -- tmux terminal multiplexer
# Installs: tmux
# Links:    ~/.config/tmux/tmux.conf
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "tmux"

if is_debian; then install_apt tmux
else install_pacman tmux
fi
link_file "$DOTFILES_HOME/.config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
