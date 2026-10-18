# 000586-wacom-tablet.sh -- Wacom Intuos S: pen follows focus, ExpressKeys work
# Installs: python-evdev
# Links:    ~/.local/bin/hypr-tablet-follow, ~/.local/bin/hypr-tablet-buttons
# Creates:  ~/.config/hypr/tablet.lua placeholder (machine-local, gitignored)
# Sets:     adds $USER to the input group (if missing)
# Enables:  --
# Note: The tablet needs no driver install: the kernel hid-wacom driver
#       (already in every installed kernel) exposes stylus, eraser and pad,
#       libwacom (a libinput dep) identifies it, and the first reboot into a
#       kernel whose modules still exist is what actually brings it up --
#       running a kernel older than the installed linux-hardened leaves no
#       wacom.ko to load, and the device binds to hid-generic with no input
#       node at all.
#
#       Two small daemons, both started by autostart.lua (`uwsm app --`, the
#       espanso 000325 pattern) so they die with the uwsm scope:
#
#       hypr-tablet-follow: Hyprland's tablet output (input:tablet:output) is
#       static config, so the daemon watches the event socket for focusedmon
#       events and rewrites the machine-local tablet.lua so the pen maps to
#       whatever monitor the mouse is active on; Hyprland's config file-watcher
#       reloads on each rewrite. Verified live on Hyprland 0.56.2: atomic
#       temp+rename rewrites are picked up by the watcher (rm+cp would stick
#       it -- the nwg-displays trap), hyprctl reload does NOT refire
#       hyprland.start handlers, and focusedmon carries the monitor name as
#       its first comma field.
#
#       hypr-tablet-buttons: Hyprland has no tablet-button binds, so this
#       daemon reads ONLY the pad evdev node (by name -- stylus and pad share
#       one USB id, which is why keyd was rejected: it grabs by id and would
#       break the pen) and injects ExpressKey macros through uinput via the
#       000325 udev rule: undo, redo, save, eraser for Xournal++. The
#       button-to-code ORDER needs one live verification after the reboot
#       (press each ExpressKey, read journalctl --user --grep
#       hypr-tablet-buttons, fix BUTTONS in the script). input-remapper would
#       be the off-the-shelf tool but it is AUR-only, excluded by policy.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "wacom-tablet"

# evdev for hypr-tablet-buttons; the follow daemon is stdlib-only.
install_pacman python-evdev

# Both daemons need to read /dev/input/event* (0660 root:input) and the
# buttons daemon injects through /dev/uinput (000325's udev rule grants the
# input group). Same group as espanso (000325), re-asserted here so this
# migration stands alone if espanso is ever removed.
if groups "$USER" | grep -qw input; then
  skip "$USER already in input group"
elif sudo usermod -aG input "$USER"; then
  warn "added $USER to input group -- log out and back in for this to take effect"
  _add_warning "log out and back in for input group membership to take effect"
else
  warn "failed to add $USER to input group"
  _add_warning "usermod -aG input $USER failed; add manually: sudo usermod -aG input $USER"
fi

link_file "$DOTFILES_HOME/.local/bin/hypr-tablet-follow" \
  "$HOME/.local/bin/hypr-tablet-follow"
link_file "$DOTFILES_HOME/.local/bin/hypr-tablet-buttons" \
  "$HOME/.local/bin/hypr-tablet-buttons"

# Machine-local tablet.lua placeholder (real file, NOT a symlink) so the
# require("./tablet.lua") call in hyprland.lua resolves on a fresh deploy.
# hypr-tablet-follow overwrites it with the focused monitor at login.
_target="$HOME/.config/hypr/tablet.lua"
if [[ ! -e "$_target" ]]; then
  : > "$_target"
  info "created empty placeholder: ~/.config/hypr/tablet.lua (written by hypr-tablet-follow)"
fi

ok "wacom-tablet"
