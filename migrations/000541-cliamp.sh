# 000541-cliamp.sh — cliamp (terminal music player)
# Installs: cliamp
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "cliamp"

install_aur cliamp
