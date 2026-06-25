# 000500-calcure.sh — calcure (TUI calendar) + config
# Installs: calcure
# Links:    ~/.config/calcure/config.ini
# Enables:  —
# Note: calendar-tui (in personal-admin-scripts) launches calcure.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "calcure"

install_aur calcure
link_file "$DOTFILES_HOME/.config/calcure/config.ini" "$HOME/.config/calcure/config.ini"
