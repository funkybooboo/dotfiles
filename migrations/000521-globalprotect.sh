# 000521-globalprotect.sh — GlobalProtect OpenConnect VPN client
# Installs: — (uninstalled; install_pacman line commented out)
# Links:    —
# Enables:  —
# Note: Switched from the AUR globalprotect-openconnect-git to the official
#       Arch repo package (extra/globalprotect-openconnect). The -git package
#       is removed. The install_pacman for the official package is COMMENTED OUT
#       because the user has a license but isn't actively using it, and wants
#       to free disk. Uncomment the install_pacman line below to re-enable.
#       Caveat: the official package (2.5.4) may lag the -git version
#       (2.6.4+); revisit if a 2.6.x feature is needed.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "globalprotect"

remove_pkg globalprotect-openconnect-git
# install_pacman globalprotect-openconnect
remove_pkg globalprotect-openconnect
