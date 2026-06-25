# 000021-plymouth.sh — Plymouth boot splash
# Installs: plymouth
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "Plymouth"

install_pacman plymouth
ok "Plymouth"
