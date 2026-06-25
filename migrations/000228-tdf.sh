# 000228-tdf.sh — tdf (terminal PDF viewer)
# Installs: tdf
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "tdf"

install_aur tdf
