# 000226-socat.sh — socat (multipurpose relay)
# Installs: socat
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "socat"

install_pacman socat
