# 000103-atuin.sh -- Atuin shell history
# Installs: atuin
# Links:    ~/.config/atuin/config.toml
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "atuin"

if is_debian; then install_apt atuin
else install_pacman atuin
fi
link_file "$DOTFILES_HOME/.config/atuin/config.toml" "$HOME/.config/atuin/config.toml"
