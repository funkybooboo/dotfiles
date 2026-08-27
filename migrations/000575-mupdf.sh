# 000575-mupdf.sh -- mupdf (pacman / apt)
# Installs: mupdf
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. mupdf is the Arch official
#       build (extra/, GPG-signed). It ships /usr/share/applications/mupdf.desktop
#       with MimeType=application/epub+zip;application/pdf;application/x-cbz;...
#       so the pre-existing `application/epub+zip=mupdf.desktop` entry in
#       ~/.config/mimeapps.list (which was dangling -- package was not
#       installed, so xdg-mime fell back to evince/nothing) now resolves
#       against the packaged desktop file. No custom .desktop needed.
#       mupdf is an X11 viewer (libx11); under Hyprland it runs via XWayland,
#       which is already available (000310).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "mupdf"

if is_debian; then
  install_apt mupdf
else
  install_pacman mupdf
fi

# Refresh the user desktop database so xdg-mime / launchers pick up the
# newly packaged mupdf.desktop immediately (without waiting for the next
# session). Non-fatal: update-desktop-database may be absent on a minimal
# install.
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

ok "mupdf"
