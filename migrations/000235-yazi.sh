# 000235-yazi.sh -- Yazi terminal file manager
# Installs: yazi
# Links:    ~/.config/yazi/yazi.toml
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "yazi"

install_pacman yazi
link_file "$DOTFILES_HOME/.config/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
