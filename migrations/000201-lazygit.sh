# 000201-lazygit.sh — lazygit TUI for git
# Installs: lazygit
# Links:    ~/.config/lazygit/config.yml
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "lazygit"

install_aur lazygit
link_file "$DOTFILES_HOME/.config/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
