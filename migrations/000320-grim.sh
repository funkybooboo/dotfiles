# 000320-grim.sh — grim (Wayland screenshot utility)
# Installs: grim
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "grim"

install_pacman grim
