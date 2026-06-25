# 000539-signal-desktop.sh — Signal desktop messenger
# Installs: signal-desktop
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "signal-desktop"

install_aur signal-desktop
