# 000012-graphical-session-keeper.sh -- hold graphical-session.target up + retire stale user units
# Installs: --
# Links:    ~/.config/systemd/user/graphical-session-keeper.service
# Enables:  graphical-session-keeper.service
# Note: THE INCIDENT this prevents. The stock graphical-session.target ships
#       StopWhenUnneeded=yes + RefuseManualStart=yes: it stops as soon as no
#       running unit requires it, and `systemctl --user start
#       graphical-session.target` is refused outright (verified live: "Operation
#       refused, unit graphical-session.target may be requested by dependency
#       only"). Before quickshell, hypr-wallpaper.service was the only unit
#       requiring it (a side effect of its BindsTo=). During the 2026-09-17
#       migrate run on debbie, 000237-herdr's enable_user_service issued the
#       run's first `systemctl --user daemon-reload`; hypr-wallpaper's unit
#       file had just been deleted from the repo, so the reload marked the unit
#       not-found, dropped its Requires edge, found the target "unneeded" and
#       stopped it -- cascading through app-graphical.slice (PartOf=the target)
#       into waybar, mako, espanso, the portals and the ghostty running
#       migrate.sh itself. The run died at the 000237/000238 boundary, leaving
#       the machine mid-handover with no bar and a dead session target.
#       graphical-session-keeper.service is the replacement requiring unit: a
#       no-op RemainAfterExit oneshot with the same BindsTo= shape, started by
#       autostart.lua on every Hyprland boot so the target also comes up on
#       boots where uwsm misses it.
# Note: DELIBERATELY NO daemon-reload here. `systemctl enable` only writes the
#       wants symlink, and `systemctl start` auto-loads unit files the manager
#       has not seen (verified live), so the keeper can be brought up without
#       any reload. A reload issued while a session-holding unit's file is
#       missing is the exact kill window above: by the time it finishes, the
#       target is "unneeded" and the session is coming down. This migration runs
#       before every later one (000237's enable_user_service reloads), so by the
#       time any reload happens the keeper already holds the target.
# Note: ORDER MATTERS: the keeper is started BEFORE the stale sweep, so a live
#       fleet machine's target never has zero requiring units at any point in
#       the transition -- sweeping first would stop hypr-wallpaper (or let the
#       next reload drop it) while nothing else required the target, tearing
#       the session down mid-run all over again.
# Note: THE SWEEP covers every symlink under ~/.config/systemd/user whose
#       target no longer exists (unit links and their .wants/ enablement links
#       alike), not just the ones 000328 names: any repo unit retirement leaves
#       exactly this dangling-link shape behind on every machine that ran the
#       old migration, and the enabled-not-found pair is what turned a routine
#       reload into a session teardown. Swept units that are still running are
#       stopped here (safe now -- the keeper holds the target); stopping them is
#       the retiring migration's job only when it knows what replaces them, and
#       this is the one case where the repo has already declared the replacement
#       by deleting the unit.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "graphical session keeper"

_units_dir="$HOME/.config/systemd/user"

# --- 1. install + enable the keeper (no manager reload; see header note) ------
link_file "$DOTFILES_HOME/.config/systemd/user/graphical-session-keeper.service" \
  "$HOME/.config/systemd/user/graphical-session-keeper.service"

# Plain `enable`, never enable_user_service: that helper daemon-reloads FIRST,
# which on a machine whose hypr-wallpaper.service is still dangling is the kill
# window the header describes. `enable` only writes the wants symlink.
if systemctl --user is-enabled --quiet graphical-session-keeper.service 2>/dev/null; then
  ok "graphical-session-keeper.service (already enabled)"
elif systemctl --user enable graphical-session-keeper.service &>/dev/null; then
  ok "graphical-session-keeper.service (enabled)"
else
  warn "failed to enable graphical-session-keeper.service"
  _add_warning "could not enable graphical-session-keeper.service"
fi

# Start only from inside a graphical session: on a fresh-install TTY run there
# is no session to keep, and pulling the target up would start the portals and
# gvfs into a headless login. autostart.lua starts the keeper on every Hyprland
# boot, and `start` auto-loads the fresh unit file, so no reload is needed.
if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
  if systemctl --user start graphical-session-keeper.service 2>/dev/null; then
    ok "graphical-session-keeper.service (started; target held)"
  else
    warn "failed to start graphical-session-keeper.service"
    _add_warning "could not start graphical-session-keeper.service"
  fi
else
  skip "keeper start (no graphical session this run; autostart.lua owns it)"
fi

# --- 2. sweep retired user units ---------------------------------------------
# Broken symlinks only: every unit this tree ever contained was linked here by a
# migration or written by `systemctl enable`, so a dangling link means the repo
# deleted the unit (unlink_stale applies the same exact test per path).
if [[ -d "$_units_dir" ]]; then
  declare -A _retired=()
  while IFS= read -r -d '' _link; do
    _unit="$(basename "$_link")"
    unlink_stale "$_link"
    _retired["$_unit"]=1
  done < <(find "$_units_dir" -xtype l \
             \( -name '*.service' -o -name '*.socket' -o -name '*.timer' \
                -o -name '*.target' -o -name '*.path' -o -name '*.slice' \) \
             -print0 2>/dev/null)

  # A swept unit can still be running from the deleted file (loaded units
  # survive unit-file deletion as "not-found active"). Stop it now: the keeper
  # already holds the target, so this cannot cascade, and a Restart=always unit
  # would otherwise respawn against a binary that no longer exists forever.
  for _unit in "${!_retired[@]}"; do
    if systemctl --user is-active --quiet "$_unit" 2>/dev/null; then
      if systemctl --user stop "$_unit" 2>/dev/null; then
        warn "stopped retired unit still running: $_unit"
        _add_warning "retired user unit was still running and was stopped: $_unit"
      else
        warn "failed to stop retired unit: $_unit"
        _add_warning "retired user unit would not stop: $_unit"
      fi
    fi
    systemctl --user reset-failed "$_unit" 2>/dev/null || true
  done
fi

ok "graphical session keeper"