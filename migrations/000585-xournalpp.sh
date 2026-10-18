# 000585-xournalpp.sh -- Xournal++ (pacman)
# Installs: xournalpp
# Links:    ~/.config/xournalpp/** (dark drawing setup + pen barrel buttons)
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
#
#       The tracked settings.xml curates the drawing setup: forceDark theme,
#       black workspace background, white default pen, plain black LANDSCAPE
#       page template (fills a widescreen instead of ruled white A4 portrait),
#       and the pen barrel buttons (settings.xml `stylus`/`stylus2` entries,
#       which map to GDK buttons 2/3 of the pen device per
#       StylusInputHandler::changeTool): lower = eraser, upper = hand (pan).
#       They ship as tool=none upstream, i.e. deliberately dead. Whether the
#       compositor delivers them at all is machine-dependent; if they do
#       nothing on a fresh machine, check Hyprland's
#       input:tablettool:eraser_button_mode override.
#
#       settings.xml is symlinked, so Xournal++ writes its own state (window
#       size, recent page colors, device entries) straight into this repo --
#       that drift is expected, like espanso's config. Swap only while
#       Xournal++ is closed: it rewrites the whole file on exit.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "xournalpp"

install_pacman xournalpp

link_tree "$DOTFILES_HOME/.config/xournalpp" "$HOME/.config/xournalpp"

ok "xournalpp"
