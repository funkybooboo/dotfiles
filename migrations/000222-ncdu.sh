# 000222-ncdu.sh — ncdu (disk usage analyzer)
# Installs: ncdu
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "ncdu"

install_pacman ncdu
