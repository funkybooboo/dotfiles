# 000219-tealdeer.sh — tealdeer (tldr pages client)
# Installs: tealdeer
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "tealdeer"

install_pacman tealdeer
