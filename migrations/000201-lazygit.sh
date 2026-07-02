# 000201-lazygit.sh -- lazygit TUI for git
# Installs: lazygit
# Links:    ~/.config/lazygit/config.yml
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "lazygit"

if is_debian; then install_apt lazygit
else install_aur lazygit
fi
link_file "$DOTFILES_HOME/.config/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
