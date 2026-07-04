# 000545-rpi-imager.sh -- Raspberry Pi Imager (graphical SD card imager)
# Installs: rpi-imager (official extra repo)
# Links:    --
# Enables:  --
# Note: rpi-imager is the official Raspberry Pi imaging utility, packaged in
#       the Arch extra repository. It ships a polkit policy and runs as the
#       normal user, elevating only for the actual block-device write -- so
#       it needs no sudo and no X/Wayland authorization workaround, unlike
#       the upstream AppImage which only bundles the Qt xcb plugin and fails
#       to connect to XWayland when launched via sudo. Optional dosfstools is
#       pulled in for SD card bootloader support.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "rpi-imager"

install_pacman rpi-imager

# dosfstools enables the "SD card bootloader" preparation step; non-fatal.
install_pacman dosfstools