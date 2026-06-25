# 000324-wtype.sh — wtype (Wayland virtual keyboard)
# Installs: wtype
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "wtype"

install_pacman wtype
