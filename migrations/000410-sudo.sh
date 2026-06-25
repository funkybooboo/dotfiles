# 000410-sudo.sh — sudo
# Installs: sudo
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "sudo"

install_pacman sudo
