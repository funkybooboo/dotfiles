# 000540-losslesscut.sh — LosslessCut (video editor)
# Installs: losslesscut-bin
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "losslesscut"

install_aur losslesscut-bin
