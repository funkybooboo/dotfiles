# 000321-slurp.sh — slurp (Wayland region selector)
# Installs: slurp
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "slurp"

install_pacman slurp
