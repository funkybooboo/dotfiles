# 000521-globalprotect.sh — GlobalProtect OpenConnect VPN client
# Installs: globalprotect-openconnect (official Arch repo, extra/)
# Links:    —
# Enables:  —
# Note: Switched from the AUR globalprotect-openconnect-git to the official
#       Arch repo package (extra/globalprotect-openconnect). The -git package
#       is removed FIRST because both provide gpclient and conflict.
#       Caveat: the official package (2.5.4) may lag the -git version
#       (2.6.4+); revisit if a 2.6.x feature is needed.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "globalprotect"

remove_pkg globalprotect-openconnect-git
install_pacman globalprotect-openconnect
