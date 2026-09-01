# 000558-gnome-keyring.sh -- gnome-keyring (pacman)
# Installs: gnome-keyring
# Links:    --
# Enables:  --
# Disables: gnome-keyring-daemon.socket (user) -- see NOTE below.
# Note: one piece of software = one migration. gnome-keyring is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000530-desktop-apps
#       grab-bag (the apps there are independent -- not related or dependent).
#
#       The package ships two competing activation paths for the Secret
#       Service (org.freedesktop.secrets): (1) a socket-activated
#       gnome-keyring-daemon.service (pkcs11,secrets) started by
#       gnome-keyring-daemon.socket (enabled by the package preset), and
#       (2) D-Bus activation via /usr/share/dbus-1/services/
#       org.freedesktop.secrets.service (--start --components=secrets). On a
#       Hyprland session both fire on resume and race: the D-Bus-activated
#       daemon grabs the org.freedesktop.secrets name first, then the
#       socket-activated one comes up, finds "Secret Service already
#       initialized", and spams "asked to register item ... but it's already
#       registered" on every resume (dozens of warnings/journal entries).
#       We MASK the socket (and its .service) at user scope so only D-Bus
#       activation provides secrets on demand. Masking is required (not just
#       `disable`) because the package enables the socket in GLOBAL scope
#       (/etc/systemd/user/sockets.target.wants/), which a user-scope disable
#       cannot remove -- a user mask symlinks the unit to /dev/null and shadows
#       the global enable. pkcs11 certificate/key storage is lost, but nothing
#       on the Hyprland desktop uses it (no GNOME apps, no cert auth).
#       Reversible: `systemctl --user unmask gnome-keyring-daemon.socket
#       gnome-keyring-daemon.service && systemctl --user enable
#       gnome-keyring-daemon.socket`.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "gnome-keyring"

install_pacman gnome-keyring

# Mask the redundant socket-activated gnome-keyring-daemon.service to stop it
# racing D-Bus activation and spamming the journal on every resume. These are
# vendor-shipped units (no dotfiles unit file), enabled in global scope, so we
# mask them at user scope (symlinks to /dev/null under ~/.config/systemd/user/)
# which shadows the global enable -- sudo-free and reversible. Idempotent:
# masking an already-masked unit is a no-op.
for _unit in gnome-keyring-daemon.socket gnome-keyring-daemon.service; do
  if [[ "$(systemctl --user is-enabled "$_unit" 2>/dev/null)" == "masked" ]]; then
    skip "$_unit (already masked)"
  else
    if systemctl --user mask "$_unit" 2>/dev/null; then
      ok "masked: $_unit (prevents duplicate keyring daemon)"
    else
      warn "failed to mask $_unit"
      _add_warning "failed to mask systemd user unit: $_unit"
    fi
  fi
done
systemctl --user daemon-reload 2>/dev/null || true

ok "gnome-keyring"
