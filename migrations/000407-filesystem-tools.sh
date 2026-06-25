# 000407-filesystem-tools.sh — DOS/exFAT filesystem utilities
# Installs: dosfstools exfatprogs
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "filesystem tools"

install_pacman dosfstools exfatprogs
