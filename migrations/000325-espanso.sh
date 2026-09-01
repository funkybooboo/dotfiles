# 000325-espanso.sh -- espanso text expander (Wayland build)
# Installs: .#espanso-wayland (nix -- flake.nix carries why not pacman/release/AUR)
# Links:    ~/.config/espanso/**
# Deploys:  /etc/udev/rules.d/99-uinput.rules
# Sets:     adds $USER to the input group
# Enables:  --
# Note: espanso is started by Hyprland, not by its own service manager:
#       autostart.lua runs `uwsm app -- espanso daemon`. `daemon` runs in the
#       foreground so the uwsm scope actually tracks the process and it dies with
#       the session, matching how hypridle/waybar/mako start.
#       `espanso service register` is deliberately NOT used -- it writes a systemd
#       unit outside this repo, creating a second owner of espanso's lifecycle.
#       hypridle shows why that hurts: uwsm names its scope
#       app-Hyprland-hypridle-<hash>.scope, so the unrelated hypridle.service
#       makes `systemctl --user is-active hypridle` report inactive while the
#       daemon runs, and ~/.local/bin/toggle-lock is broken as a result.
#
#       This REVERSES the note in 000400-power-management.sh, which recorded that
#       the `input` group was not being re-added after swayosd went away. espanso
#       needs it: its EVDEV backend reads typed triggers straight from
#       /dev/input/event*, and on failure says so itself -- "You can either add
#       the current user to the 'input' group or run espanso as root".
#
#       Wayland support is EXPERIMENTAL upstream, with two consequences worth
#       knowing before debugging: app-specific config (filter_class /
#       filter_title) does not work under Hyprland, because espanso implements it
#       only via kdotool, which is KDE-only; and espanso opens /dev/input devices
#       once at startup, so a keyboard plugged in later is ignored until
#       `espanso restart`.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "espanso"

install_nix ".#espanso-wayland"

# Device access. espanso reads triggers from /dev/input/event* (already 0660
# root:input) and injects through /dev/uinput (root-only by default), so it needs
# the group for the first and the udev rule for the second. See the rule file for
# why this is not upstream's `setcap cap_dac_override+p`.
deploy_etc_file "$DOTFILES_ROOT_ETC/udev/rules.d/99-uinput.rules" \
  "/etc/udev/rules.d/99-uinput.rules" 644
if command -v udevadm &>/dev/null; then
  sudo udevadm control --reload-rules 2>/dev/null || true
  sudo udevadm trigger --subsystem-match=misc --sysname-match=uinput 2>/dev/null || true
fi

if groups "$USER" | grep -qw input; then
  skip "$USER already in input group"
elif sudo usermod -aG input "$USER"; then
  warn "added $USER to input group -- log out and back in for this to take effect"
  _add_warning "log out and back in for input group membership to take effect"
else
  warn "failed to add $USER to input group"
  _add_warning "usermod -aG input $USER failed; add manually: sudo usermod -aG input $USER"
fi

# Config must exist before espanso runs at all: with no config directory even
# `espanso path` aborts with "missing config directory".
link_tree "$DOTFILES_HOME/.config/espanso" "$HOME/.config/espanso"

ok "espanso"
