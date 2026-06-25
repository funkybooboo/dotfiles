# 000207-act.sh — act (run GitHub Actions locally)
# Installs: act
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "act"

install_aur act
