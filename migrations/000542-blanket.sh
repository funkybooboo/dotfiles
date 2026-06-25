# 000542-blanket.sh — Blanket (ambient sound)
# Installs: blanket
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "blanket"

install_pacman blanket
