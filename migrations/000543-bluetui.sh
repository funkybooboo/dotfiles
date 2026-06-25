# 000543-bluetui.sh — bluetui (Bluetooth TUI manager)
# Installs: bluetui
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "bluetui"

install_pacman bluetui
