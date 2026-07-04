# 000545-rpi-imager.sh -- Raspberry Pi Imager (graphical SD card imager)
# Installs: rpi-imager (official extra repo)
# Links:    --
# Enables:  --
# Note: rpi-imager is the official Raspberry Pi imaging utility, packaged in
#       the Arch extra repository (same upstream source as the AppImage, which
#       it supersedes). IMPORTANT: the 2.x binary escalates the *entire* GUI to
#       root via polkit/sudo -- it does NOT run as the normal user -- so on a
#       Wayland (Hyprland) + XWayland session the root process is rejected by
#       the X server. The GUI fix lives in 000546-rpi-imager-gui.sh (xhost
#       wrapper). Optional dosfstools is pulled in for SD card bootloader
#       support.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "rpi-imager"

install_pacman rpi-imager

# dosfstools enables the "SD card bootloader" preparation step; non-fatal.
install_pacman dosfstools