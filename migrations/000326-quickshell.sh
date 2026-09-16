# 000326-quickshell.sh -- quickshell desktop shell (QtQuick/QML)
# Installs: quickshell
# Links:    ~/.config/quickshell/ (shell.qml is picked up as the "default"
#           config, so autostart can call a bare `quickshell`)
# Removes:  waybar (pacman and nix), mako -- superseded, see the note below
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
  remove_pkg waybar mako
  remove_nix waybar
else
  warn "quickshell not on PATH -- leaving waybar/mako in place"
  _add_warning "quickshell missing; superseded waybar/mako not removed"
fi

ok "quickshell"
