# 000215-jq.sh — jq (JSON processor)
# Installs: jq
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "jq"

install_pacman jq
