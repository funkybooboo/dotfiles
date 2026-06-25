# 000322-satty.sh — satty (screenshot annotation tool)
# Installs: satty
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "satty"

install_pacman satty
