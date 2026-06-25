# 000220-unzip.sh — unzip (zip extraction)
# Installs: unzip
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "unzip"

install_pacman unzip
