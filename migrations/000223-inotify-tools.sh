# 000223-inotify-tools.sh — inotify-tools (filesystem event monitoring)
# Installs: inotify-tools
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "inotify-tools"

install_pacman inotify-tools
