# 000501-television.sh — television (TUI channel-switcher / launcher)
# Installs: television
# Links:    ~/.config/television/config.toml
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "television"

install_aur television
link_file "$DOTFILES_HOME/.config/television/config.toml" "$HOME/.config/television/config.toml"
