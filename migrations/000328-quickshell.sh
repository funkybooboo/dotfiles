# 000328-quickshell.sh -- quickshell desktop shell (QtQuick/QML)
# Installs: quickshell
# Links:    ~/.config/quickshell/ (shell.qml is picked up as the "default"
#           config, so autostart can call a bare `quickshell`)
# Enables:  --
#
# Note: one process owns the bar, tray, notifications and tooltips; it replaced
#       waybar, mako, hyprlauncher, hyprpaper, swaybg and a dozen shell scripts.
#       (The retirement sweep for machines that ran the pre-quickshell
#       migrations lived here until 2026-09-17, when the only machine converged;
#       fresh machines never run the old migrations and never see the old
#       shell.) The QML tree is byte-identical to the work repo's: it is
#       machine- and distro-independent, so only this migration differs (pacman
#       here, a source build there because quickshell is absent from apt and the
#       nixpkgs build cannot reach Ubuntu's Mesa). Bar.qml's Network click opens
#       impala where the work repo's opens nmtui -- same NetworkManager daemon
#       on both, and the work repo may follow.
#
# Note: interrogate the running shell with `quickshell ipc call shell status`.
#       With nine daemons collapsed into one process, none of the old probes
#       (`pgrep mako`, `makoctl`, `brightnessctl -m`) can report what it thinks.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "quickshell"

link_tree "$DOTFILES_HOME/.config/quickshell" "$HOME/.config/quickshell"

install_pacman quickshell

# Hand over within this run rather than at next login: a machine that just
# installed quickshell would otherwise sit with no bar until it restarted.
if ! command -v quickshell &>/dev/null; then
  warn "quickshell not on PATH"
  _add_warning "quickshell missing; bar/tray/notifications will not start"
elif pgrep -x quickshell >/dev/null; then
  skip "quickshell (already running)"
elif [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
  info "starting quickshell"
  uwsm app -- quickshell >/dev/null 2>&1 &
  disown
fi

ok "quickshell"