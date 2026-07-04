# 000546-rpi-imager-gui.sh -- rpi-imager GUI Wayland/XWayland root-access wrapper
# Installs:        xorg-xhost (official extra repo)
# Links:           ~/.local/bin/rpi-imager           (wrapper shadowing /usr/bin/rpi-imager)
#                  ~/.local/share/applications/com.raspberrypi.rpi-imager.desktop (override)
# Enables:         --
# Note:            rpi-imager escalates the whole GUI to root via polkit/sudo. On a
#                  Wayland (Hyprland) + XWayland session the re-execed root process is
#                  rejected by the X server ("Authorization required, but no
#                  authorization protocol specified" / "qt.qpa.xcb: could not connect
#                  to display :0"). This wrapper grants xhost +SI:localuser:root for
#                  the process lifetime only and revokes it on exit -- the narrow
#                  secure-intercept grant (local root only, not the network-open
#                  `xhost +`). The tracked desktop entry overrides the package's
#                  /usr/share/applications entry so menu/launcher invocations route
#                  through the wrapper too. Depends on 000545 (installs rpi-imager) and
#                  000310 (Hyprland session).
[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "rpi-imager GUI wrapper"

# xhost(1) client -- official Arch extra package.
install_pacman xorg-xhost

# Wrapper shadowing /usr/bin/rpi-imager via PATH ordering (~/.local/bin precedes
# /usr/bin). It grants the xhost entry, exec's the real binary by absolute path
# (no recursion), and revokes on exit.
link_file "$DOTFILES_HOME/.local/bin/rpi-imager" \
  "$HOME/.local/bin/rpi-imager"

# Desktop entry override so menu/launcher launches route through the wrapper
# (the package's /usr/share entry calls /usr/bin/rpi-imager directly and would
# bypass the xhost grant). ~/.local/share/applications precedes /usr/share.
link_file "$DOTFILES_HOME/.local/share/applications/com.raspberrypi.rpi-imager.desktop" \
  "$HOME/.local/share/applications/com.raspberrypi.rpi-imager.desktop"

# Remove a stale AppImage-registered URI handler if it still points at the
# deleted AppImage. Non-fatal, idempotent. The package's own system desktop
# entry (now overridden above) re-provides the x-scheme-handler/rpi-imager
# mime association, so this user-level stub is redundant once the AppImage is
# gone.
_stale="$HOME/.local/share/applications/com.raspberrypi.rpi-imager-uri-handler.desktop"
if [[ -f "$_stale" ]] && grep -q -- '/home/nate/Downloads/imager_2.0.10_amd64.AppImage' "$_stale" 2>/dev/null; then
  rm -f "$_stale"
  ok "removed stale AppImage URI handler ${_stale/$HOME/\~}"
fi

# Refresh desktop + icon caches so Hyprland menus pick up the override.
# Non-fatal: these tools may be absent on a minimal install.
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -f "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
fi

ok "rpi-imager GUI wrapper"