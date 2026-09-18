# 000329-notification-daemon.sh -- keep quickshell as the notification server
# Installs: --
# Removes:  xfce4-notifyd (apt only)
# Links:    ~/.config/autostart/xfce4-notifyd.desktop (Hidden=true tombstone)
# Disables: xfce4-notifyd.service (user), masked -- see NOTE.
# Note: one piece of software = one migration. Pairs with 000328-quickshell, which
#       installs the shell that owns org.freedesktop.Notifications.
#
#       Ubuntu pulls in xfce4-notifyd as a dependency (never manually installed
#       here, no reverse dependencies). It claims org.freedesktop.Notifications,
#       and D-Bus name ownership is first-come: once notifyd holds it, quickshell's
#       NotificationServer cannot take it and -- the part that hid this for months
#       -- logs NOTHING when it fails. The symptom is notifications that still
#       appear, drawn by a daemon whose styling has nothing to do with this shell,
#       while the repo's NotificationPopup.qml sits inert.
#
#       It has THREE ways back in, so removing the package alone is not a durable
#       fix if some future xfce-adjacent dependency reinstalls it:
#         1. /etc/xdg/autostart/xfce4-notifyd.desktop -- starts it at every login
#         2. /usr/share/dbus-1/services/org.xfce.xfce4-notifyd.Notifications.service
#            -- D-Bus activation, which fires on the first notification arriving
#            while nothing holds the name (i.e. during any quickshell restart)
#         3. SystemdService=xfce4-notifyd.service, referenced by both service files
#
#       So: remove the package for the immediate fix, and leave user-scope
#       tombstones for paths 1 and 3 that survive a reinstall. Path 2 needs no
#       tombstone once the binary is gone, and cannot win while quickshell holds
#       the name. Reversible: `rm ~/.config/autostart/xfce4-notifyd.desktop &&
#       systemctl --user unmask xfce4-notifyd.service && sudo apt install
#       xfce4-notifyd`.
#
#       Arch has no such package, so everything here is a no-op on the personal
#       machine -- kept in both repos so the two do not diverge on intent.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "notification-daemon"

remove_apt xfce4-notifyd

# A Hidden=true entry in ~/.config/autostart shadows the same basename in
# /etc/xdg/autostart (XDG desktop-entry spec), so this suppresses path 1 even if
# the package returns. Written rather than linked: it is a tombstone, not config,
# and nothing in root/ should carry a file whose only purpose is to be empty.
_autostart="$HOME/.config/autostart/xfce4-notifyd.desktop"
if [[ -f "$_autostart" ]] && grep -q '^Hidden=true' "$_autostart"; then
  skip "xfce4-notifyd autostart (already suppressed)"
else
  mkdir -p "$(dirname "$_autostart")"
  cat > "$_autostart" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=xfce4-notifyd
Hidden=true
DESKTOP
  ok "suppressed autostart: xfce4-notifyd (quickshell owns notifications)"
fi

# Path 3. Masking rather than disabling, for the same reason as 000558: a
# user-scope disable cannot remove a vendor enable, but a user-scope mask symlinks
# the unit to /dev/null and shadows it. Idempotent, sudo-free, and harmless when
# the unit does not exist -- which is the normal case here, since the package is
# gone by this point.
if [[ "$(systemctl --user is-enabled xfce4-notifyd.service 2>/dev/null)" == "masked" ]]; then
  skip "xfce4-notifyd.service (already masked)"
elif systemctl --user mask xfce4-notifyd.service 2>/dev/null; then
  ok "masked: xfce4-notifyd.service (blocks D-Bus SystemdService activation)"
else
  skip "xfce4-notifyd.service (not present)"
fi
systemctl --user daemon-reload 2>/dev/null || true

ok "notification-daemon"
