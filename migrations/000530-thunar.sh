# 000530-thunar.sh — Thunar file manager
# Installs: thunar
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "thunar"

install_pacman thunar
