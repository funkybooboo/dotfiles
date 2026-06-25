# 000213-dust.sh — dust (du replacement)
# Installs: dust
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "dust"

install_pacman dust
