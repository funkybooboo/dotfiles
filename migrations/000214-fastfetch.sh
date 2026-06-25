# 000214-fastfetch.sh — fastfetch (system info)
# Installs: fastfetch
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "fastfetch"

install_pacman fastfetch
