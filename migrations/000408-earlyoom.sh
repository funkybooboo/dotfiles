# 000408-earlyoom.sh — earlyoom (OOM killer daemon)
# Installs: earlyoom
# Links:    —
# Enables:  earlyoom.service

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "earlyoom"

install_pacman earlyoom
enable_system_service "earlyoom.service"
