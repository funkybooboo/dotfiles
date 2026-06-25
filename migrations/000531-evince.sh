# 000531-evince.sh — Evince document viewer
# Installs: evince
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "evince"

install_pacman evince
