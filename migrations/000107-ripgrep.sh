# 000107-ripgrep.sh -- ripgrep (grep replacement) + config
# Installs: ripgrep
# Links:    ~/.config/ripgrep/config
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "ripgrep"

if is_debian; then install_apt ripgrep
else install_pacman ripgrep
fi
link_file "$DOTFILES_HOME/.config/ripgrep/config" "$HOME/.config/ripgrep/config"
