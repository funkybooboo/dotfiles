# 000205-lazydocker.sh — lazydocker TUI for Docker/Podman
# Installs: lazydocker
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "lazydocker"

install_aur lazydocker
