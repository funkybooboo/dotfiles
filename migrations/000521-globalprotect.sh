# 000521-globalprotect.sh — GlobalProtect OpenConnect VPN client
# Installs: globalprotect-openconnect-git
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "globalprotect"

install_aur globalprotect-openconnect-git
