# 000221-rsync.sh — rsync (file synchronization)
# Installs: rsync
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "rsync"

install_pacman rsync
