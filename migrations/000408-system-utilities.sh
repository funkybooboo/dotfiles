# 000408-system-utilities.sh — system service & maintenance utilities
# Installs (pacman): earlyoom fwupd yazi man-db less zram-generator
# Links:    —
# Enables:  earlyoom.service (started — safe, won't disrupt the session)
# Note: fwupd is on-demand via fwupdmgr (used by the update-firmware admin
#       script). zram-generator auto-starts via udev on boot. yazi is a
#       terminal file manager. man-db+less provide man pages.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "system utilities"

install_pacman earlyoom fwupd yazi man-db less zram-generator

enable_system_service "earlyoom.service"

ok "system utilities"
