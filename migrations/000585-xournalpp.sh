# 000585-xournalpp.sh -- Xournal++ (pacman)
# Installs: xournalpp
# Links:    --
# Enables:  --
# Note: Xournal++ is the handwriting/annotation app for the Wacom Intuos S
#       (CTL-4100). Pressure arrives via libinput -- the tablet itself needs
#       no other software on Wayland: the kernel hid-wacom driver exposes the
#       stylus (already in every installed kernel), libwacom (a libinput dep)
#       identifies it, and Hyprland maps it (see 000586). The first reboot
#       into a kernel whose modules still exist is what actually brings the
#       tablet up: running a kernel older than the installed linux-hardened
#       leaves no wacom.ko to load, and the device binds to hid-generic with
#       no input node at all. Verify pressure after that in
#       Edit -> Preferences -> Input Devices.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "xournalpp"

install_pacman xournalpp

ok "xournalpp"
