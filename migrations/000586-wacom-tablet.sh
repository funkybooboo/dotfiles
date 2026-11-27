# 000586-wacom-tablet.sh -- Wacom Intuos S: pen follows focus, ExpressKeys work
# Installs: python-evdev
# Links:    ~/.local/bin/hypr-tablet-follow, ~/.local/bin/hypr-tablet-buttons
# Deploys:  /etc/udev/rules.d/90-wacom-pad-libinput-ignore.rules
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
#       events and applies the focused monitor AT RUNTIME via
#       `hyprctl eval 'hl.config({ input = { tablet = { output = "NAME" } } })'`.
#       The original mechanism rewrote the machine-local tablet.lua and leaned
#       on the config file-watcher's auto-reload -- replaced 2026-11-21 because
#       a config reload KILLS any active window drag: every super+drag across
#       a monitor boundary died at the boundary (one focusedmon, one write, one
#       mid-drag reload, and the focus churn often made it fire twice). Verified
#       live on Hyprland 0.57.1: the eval path changes input:tablet:output with
#       NO configreloaded event and drags survive crossings. tablet.lua remains
#       as the login-time default, and the daemon re-syncs after every
#       configreloaded event so a manual reload cannot leave the pen stale.
#       The old file-write version was verified on 0.56.2 if ever needed again:
#       atomic temp+rename rewrites are picked up by the watcher (rm+cp would
#       stick it -- the nwg-displays trap), hyprctl reload does NOT refire
#       hyprland.start handlers, and focusedmon carries the monitor name as
#       its first comma field.
#
#       hypr-tablet-buttons: Hyprland has no tablet-button binds, so this
#       daemon reads ONLY the pad evdev node (by name -- stylus and pad share
#       one USB id, which is why keyd was rejected: it grabs by id and would
#       break the pen) and injects macros through uinput via the 000325 udev
#       rule. The focus guard is a per-app map (FOCUS_MAP in the script),
#       Xournal++ (undo/redo/save/eraser) and LibreWolf (Excalidraw undo/
#       redo/hold-space-pan/pencil, since the hosted excalidraw instance is
#       a taskbar tab inside LibreWolf): injected keys land in the focused
#       window, and a global guard once sent ctrl+z into a coding-agent
#       terminal and killed the session. Its shebang is pinned to
#       /usr/bin/python3, the interpreter pacman installs python-evdev for
#       -- `env python3` may resolve to a mise python without it and die
#       silently, and `uwsm app` does not journal daemon stderr, so that
#       death would be invisible. To see pad button codes, run
#       ~/.local/bin/hypr-tablet-buttons in a terminal (stderr is not
#       journaled) and fix FOCUS_MAP in the script if the order is off.
#       input-remapper would be the off-the-shelf tool but it is AUR-only,
#       excluded by policy.
#
#       The pad is also hidden from libinput by the deployed udev rule:
#       Wayland tablet-pad events crash every unfocused GTK4 app (GTK #8298,
#       the 2026-11-27 ghostty incident -- see the rule file for the trail).
#       The rule needs the tablet REPLUGGED (or a reboot) to take effect on
#       a compositor that already enumerated the pad; the daemon is
#       unaffected either way, it reads the raw evdev node.

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

# Hide the pad from libinput: Wayland tablet-pad events crash every
# unfocused GTK4 app (see the rule's header comment). Idempotent deploys
# plus a rules reload; a live compositor only drops an already-enumerated
# pad on replug/reboot, warned below.
deploy_etc_file "$DOTFILES_ROOT_ETC/udev/rules.d/90-wacom-pad-libinput-ignore.rules" \
  "/etc/udev/rules.d/90-wacom-pad-libinput-ignore.rules" 644
if sudo udevadm control --reload-rules 2>/dev/null; then
  ok "udev rules reloaded"
else
  _add_warning "udevadm control --reload-rules failed -- reboot to pick up the pad rule"
fi

# Machine-local tablet.lua placeholder (real file, NOT a symlink) so the
# require("./tablet.lua") call in hyprland.lua resolves on a fresh deploy.
# hypr-tablet-follow overwrites it with the focused monitor at login.
_target="$HOME/.config/hypr/tablet.lua"
if [[ ! -e "$_target" ]]; then
  : > "$_target"
  info "created empty placeholder: ~/.config/hypr/tablet.lua (written by hypr-tablet-follow)"
fi

ok "wacom-tablet"
