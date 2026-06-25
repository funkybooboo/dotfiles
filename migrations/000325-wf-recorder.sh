# 000325-wf-recorder.sh — wf-recorder (Wayland screen recorder)
# Installs: wf-recorder
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "wf-recorder"

install_pacman wf-recorder
