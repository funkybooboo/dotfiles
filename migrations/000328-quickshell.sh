# 000328-quickshell.sh -- quickshell desktop shell (QtQuick/QML)
# Installs: quickshell
# Links:    ~/.config/quickshell/ (shell.qml is picked up as the "default"
#           config, so autostart can call a bare `quickshell`)
# Removes:  waybar (pacman and nix), mako, hyprlauncher, hyprpaper, swaybg,
#           hypr-wallpaper.service, and the media-keys, clipboard-manager and
#           hypr-window-switcher scripts -- superseded, see the note below
# Enables:  --
#
# Note: one process now owns the bar, tray, notifications and tooltips, replacing
#       waybar and mako. The QML tree is byte-identical to the work repo's: it is
#       machine- and distro-independent, so only this migration differs (pacman
#       here, a source build there because quickshell is absent from apt and the
#       nixpkgs build cannot reach Ubuntu's Mesa).
#
# Note: CONVERGENCE. Deleting the old waybar and mako migrations stops a fresh
#       machine ever installing them, but does nothing to a machine that already
#       ran them, so the removals are explicit here. They run last, after
#       quickshell is in place: uninstalling the old shell first would leave a
#       machine with no bar at all if the install then failed. The nix sweep
#       covers 000574's patched waybar, which shadowed the pacman one on PATH --
#       dropping the flake attr does not uninstall it.
#
# Note: interrogate the running shell with `quickshell ipc call shell status`.
#       With nine daemons collapsed into one process, none of the old probes
#       (`pgrep mako`, `makoctl`, `brightnessctl -m`) can report what it thinks.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "quickshell"

link_tree "$DOTFILES_HOME/.config/quickshell" "$HOME/.config/quickshell"

install_pacman quickshell

# Only sweep the old shell once the new one answers, so a converging run cannot
# strand a machine between the two.
if command -v quickshell &>/dev/null; then
  remove_pkg waybar mako hyprlauncher hyprpaper swaybg
  remove_nix waybar

  # Restart=always means this one never stops on its own; the unit file being
  # deleted from the repo does not disable the enabled symlink.
  disable_user_service "hypr-wallpaper.service"

  # Superseded scripts and configs leave dangling links once their sources are
  # deleted from the repo: media-keys by the shell's volume/brightness handling,
  # hyprlauncher.conf by the native launcher, and hyprtoolkit.conf because
  # hyprlauncher was the only thing that read it.
  unlink_stale \
    "$HOME/.local/bin/media-keys" \
    "$HOME/.local/bin/clipboard-manager" \
    "$HOME/.local/bin/nightmode-indicator" \
    "$HOME/.local/bin/keepawake-indicator" \
    "$HOME/.local/bin/recording-indicator" \
    "$HOME/.local/bin/theme-switch" \
    "$HOME/.local/bin/hypr-window-switcher" \
    "$HOME/.local/bin/hypr-window-switcher-inner" \
    "$HOME/.config/hyprlauncher/hyprlauncher.conf" \
    "$HOME/.config/hypr/hyprtoolkit.conf" \
    "$HOME/.config/hypr/set-wallpaper.sh" \
    "$HOME/.config/hypr/monitor-watcher.sh" \
    "$HOME/.config/systemd/user/hypr-wallpaper.service"

  # Hand over within this run rather than at next login. An already-running
  # waybar or mako keeps going from deleted files, and a machine that just
  # uninstalled waybar would otherwise sit with no bar until it restarted.
  # `.mako-wrapped` is mako's real process name once nix wraps the binary, so
  # matching only `mako` silently misses it.
  pkill -x waybar || true
  pkill -x mako || true
  pkill -x .mako-wrapped || true

  if pgrep -x quickshell >/dev/null; then
    skip "quickshell (already running)"
  elif [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    info "starting quickshell"
    uwsm app -- quickshell >/dev/null 2>&1 &
    disown
  fi
else
  warn "quickshell not on PATH -- leaving waybar/mako in place"
  _add_warning "quickshell missing; superseded waybar/mako not removed"
fi

ok "quickshell"
