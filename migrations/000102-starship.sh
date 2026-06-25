# 000102-starship.sh — Starship cross-shell prompt
# Installs: starship
# Links:    ~/.config/starship.toml
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "starship"

install_pacman starship
link_file "$DOTFILES_HOME/.config/starship.toml" "$HOME/.config/starship.toml"
