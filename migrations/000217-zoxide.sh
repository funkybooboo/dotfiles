# 000217-zoxide.sh — zoxide (smarter cd)
# Installs: zoxide
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "zoxide"

install_pacman zoxide
