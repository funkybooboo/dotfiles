# 000412-yazi.sh — yazi (terminal file manager)
# Installs: yazi
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "yazi"

install_pacman yazi
