# 000543-caligula.sh — caligula disk imaging TUI
# Installs: caligula (official extra repo)
# Links:    —
# Enables:  —
# Note: caligula is a user-friendly, lightweight TUI for disk imaging,
#       in the official Arch extra repository.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "caligula"

install_pacman caligula
