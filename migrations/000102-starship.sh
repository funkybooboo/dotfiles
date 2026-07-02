# 000102-starship.sh -- Starship cross-shell prompt
# Installs: starship
# Links:    ~/.config/starship.toml
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "starship"

if is_debian; then install_apt starship
else install_pacman starship
fi
link_file "$DOTFILES_HOME/.config/starship.toml" "$HOME/.config/starship.toml"
