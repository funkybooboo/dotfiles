---
name: hyprland
description: >
  Hyprland Lua config reference for this dotfiles setup: Lua API facts (require
  paths, hyprctl dispatch/eval, reload full-reset, window rules), the media-keys
  wrapper and its traps, waybar workspace modules (PR #5013 overlay), window
  switcher, touchpad gestures. Triggers: hyprland, hypr, hyprctl, hl.dsp,
  hl.monitor, bindings.lua, hyprland.lua, window rule, submap, waybar, swayosd,
  media-keys, brightness keys, volume keys, workspace click, monitor disable.
---

# Hyprland (Lua config) reference

## Config layout (hyprlang -> hyprland.lua, commits 48b0c3c + 199447d)

- ~/.config/hypr/hyprland.lua (entry) +
  lua/{env,autostart,input,looknfeel,windows,bindings,workspaces}.lua, all
  symlinked from ~/dotfiles. monitors.lua is MACHINE-LOCAL (nwg-displays output,
  gitignored, real file). hypridle/hyprlock/hyprpaper/hyprtoolkit/mako .conf
  files are other programs' configs -- keep their native format.
- Migration 000322 re-link_trees the hypr dir, removes stale .conf symlinks
  (hyprland.lua is ignored while a hyprland.conf exists), git rm --cached's
  monitors.lua.

## Lua API facts (verified against Hyprland 0.56.2 source)

- require uses explicit relative path WITH extension:
  `require("./lua/env.lua")` -- bare "lua/env" does NOT resolve.
- `hyprctl reload full-reset` flushes the statically-cached config path; plain
  `reload` reuses it. USE full-reset when switching config formats or when a
  file-watcher reload got stuck from a momentarily-absent file (manual rm+cp
  triggers the stuck state; nwg-displays' atomic temp+rename does not).
- Window-rule effects: size/move take a TABLE of two values (string expressions
  OK, e.g. {"monitor_w * 0.85", "monitor_h * 0.90"}); opacity="0.97 0.9";
  suppress_event="maximize"; idle_inhibit="always" (underscore, NOT idleinhibit).
  Match props: class/title/initial_class/initial_title/tag/xwayland/float/
  fullscreen/pin.
- Dispatchers: hl.dsp.window.{close,float,resize,center,move,fullscreen,drag,
  pseudo,pin}({...}); resize({x,y,relative=true}) is additive; move({workspace=,
  follow=false}) is silent; hl.dsp.focus({direction=}|{workspace=}|{window=
  "address:.."}); hl.dsp.group.{toggle,next,prev}() no-arg;
  hl.dsp.workspace.toggle_special("name"); hl.dsp.layout("togglesplit");
  hl.dsp.exec_cmd(str).
- `hyprctl dispatch '<lua-expr>'` wraps as hl.dispatch(<lua-expr>) -- the arg
  MUST be a Lua expression. `hyprctl dispatch workspace 4` (legacy multi-word
  args) is DEAD: wraps as hl.dispatch(workspace 4), a Lua syntax error, and
  errors are easy to miss because every caller silences output. Workspace
  switch: `hyprctl dispatch 'hl.dsp.focus({workspace=N})'`. `hyprctl eval
  '<lua>'` for top-level (hl.monitor etc.). `hyprctl keyword` is GONE in Lua
  mode.
- Quickshell 0.3.1's Hyprland.dispatch sends the dead legacy frame too --
  Workspaces.qml's click therefore shells out via
  Quickshell.execDetached(["hyprctl","dispatch","hl.dsp.focus({workspace=N})"])
  (same convention as the hypr-* scripts); when a Lua-IPC-speaking quickshell
  lands in pacman, Hyprland.dispatch can come back. The singleton's
  usingLua/requestSocketPath/eventSocketPath properties are live probes
  (verified: event socket + workspaces model work; only the request frame is
  wrong).

## Quickshell IPC + hot-reload

- Keybind side: bare `quickshell ipc call shell <fn>` works (Hyprland's exec
  PATH has /usr/bin; only ~/.local/bin needs absolute paths).
- QML-side debugging trick: restart with stderr captured via
  `uwsm app -- sh -c "exec quickshell 2>>~/.cache/qs-debug.log"` (plain
  `uwsm app -- quickshell` sends stderr nowhere findable; the journal has
  nothing).
- HOT-RELOAD DOES NOT FIRE on link_tree'd QML files replaced by sed -i / editors
  that rename-replace (the watcher holds the replaced inode; verified live:
  edits sat unapplied through three reload attempts). After editing the repo's
  QML, restart quickshell. From agent bash, launch via the compositor so the
  process is not a child of the tool call (a foreground `uwsm app -- quickshell`
  from the bash tool BLOCKS the call and dies when it aborts):
  `hyprctl dispatch 'hl.dsp.exec_cmd("uwsm app -- quickshell")'`. stderr goes to
  quickshell's own log at /run/user/1000/quickshell/by-id/<id>/log.qslog (binary
  framing; grep --text). A new .qml file in the repo is NOT visible to a running
  shell until it is symlinked into the live ~/.config/quickshell/ -- otherwise
  the load dies with "X is not a type". QML's JS engine (V4) rejects OBJECT
  spread `{...obj}` outright (array spread `[...a, b]` is fine) and quickshell
  has no QtQuick.Controls in this config by design.
- RESTART MEANS KILL FIRST: quickshell is NOT single-instance. A plain
  relaunch leaves the old instance running beside the new one, both
  rendering the bar/panels, and the orphan grows (2026-11-06: a 09:09
  instance survived two relaunches, peaked 3.1G RSS + 600M swap over 2.5h
  -- repeated config-reload churn does not return QML memory -- until
  earlyoom shot it; its replacement idled at 83M). Restarting is
  desktop-visible (bar blinks off/on) and needs the user's go-ahead; then
  `pkill -x quickshell` (exact name -- no self-match trap), wait a beat,
  then the hyprctl dispatch exec_cmd above. Orphan check: `pgrep -a
  quickshell` (also check RSS: an instance far above ~100M after a
  dev-heavy session needs a restart).
- Debug probes: temp IpcHandler function in shell.qml callable via
  `quickshell ipc call shell <name>` gives a fully remote test loop (state +
  dispatch + returns) without touching the mouse.
- Window selectors need the "address:" prefix (hyprctl reports bare 0x..;
  the bare form does not resolve). Key names are case-insensitive.
- hl.monitor fields: output, mode ("2256x1504@60.0" | "preferred"), position,
  scale, disabled (bool), transform, reserved. Disable a panel:
  {output=..., disabled=true}.
- `hyprctl binds -j` returns dispatcher='__lua' for every bind -- unusable for
  reconstruction; the hypr-keybinds cheatsheet parses bindings.lua source.
- Float-at-creation: window rule on initial_title="^(hypr-float.*)$" +
  hypr-float-launch -- no tile-then-float flash.
- Do NOT live-test destructive scripts (hypr-kill-workspace closes ALL windows
  on the ACTIVE workspace; a switch that hasn't landed kills your own terminal).

## media-keys wrapper (~/.local/bin/media-keys, linked by migration 000310)

- Volume via wpctl (VOL_MAX=150, fallback cap -l 1.5), brightness via
  brightnessctl. NO OSD -- the user prefers live waybar icon+percent; swayosd
  is unused (autostart removed).
- TRAPS: (1) Hyprland's exec PATH does NOT include ~/.local/bin -- binds MUST
  use explicit ~/.local/bin/<script> paths (bare names are "command not found"
  on keypress; interactive-shell testing misses this). (2) swayosd 0.3.2
  brightness is BROKEN on intel_backlight max 192000 (raise no-ops/lowers,
  lower RAISES, returns rc=0 instantly -- hang-detectors never catch it).
  (3) keep migration 000314-swayosd.sh: its udev rule + video-group membership
  are what let brightnessctl write /sys/class/backlight/* at all.

## Waybar

- Workspace CLICK works: the dotfiles nix flake overlays waybar with upstream
  PR #5013 (stock waybar 0.15.0 hardcodes the dead legacy `workspace`
  dispatcher, which no-ops under Hyprland's Lua IPC). overlays/waybar-pr5013.patch.
- Workspaces module = native hyprland/workspaces, original git-HEAD theme (the
  user explicitly reverted a custom look). The custom/wsN modules +
  waybar-ws-daemon (systemd user service) built before the overlay are dead
  code, kept only for revival if the overlay is dropped.
- Workspace switching by mouse: 3-finger horizontal touchpad gesture (native
  `hl.gesture({fingers=3, direction="horizontal", action="workspace"})`, no
  plugin) -- super+scroll AND super+drag are dead on multi-device machines
  (upstream PR #14633 aggregates modifier state across keyboard-like devices;
  modifier-less devices overwrite SUPER on focus-enter; no config workaround).
- waybar hyprland/workspaces on-scroll does NOT fire for touchpad scroll
  (gdk_event_get_pointer_emulated first-line check); external mouse wheel OK.
- PATTERN (daemon work): setsid -f + bash event loops are INCOMPATIBLE (fork
  signal race kills socat/coproc children); the robust pattern is a systemd
  USER service + process substitution. Hyprland event socket:
  ${XDG_RUNTIME_DIR}/hypr/*/.socket2.sock (the FILENAME carries the dot; the
  instance directory does NOT).

## Window switcher (Super+/)

- hypr-window-switcher-inner uses jq `@tsv` (NOT @csv) -- fzf --delimiter='\t'
  and cut -f1/-f2 expect real tabs or Enter dispatches garbage.

## Notifications (quickshell, commits 4490f8e + fbe8491)

- Model: toasts and the super+N panel are two views of one in-memory list
  (server.trackedNotifications, cap 50, arrival-order). close() hides from the
  toast stack only (it stays in history); remove()/removeAll() (dismiss()) are
  the only deleting paths; activate() = default action else
  Compositor.focusWindowFor(). Toast: click activate, right-click/X close only,
  X top-right with appName reserving Theme.notificationCloseReserve (24).
  Panel: newest first, relative ages from Notifications.received (Notification
  has no time property), Clear + same DND toggle as the bell. NO cross-reboot
  persistence (quickshell persistenceSupported is a spec advertisement,
  keepOnReload covers config reloads only).
- Bar bell: click toggles silent mode (doNotDisturb -- suppresses toasts, never
  tracking), right-click opens the panel; ipc notificationPanel() + history count
  in status(). Keybind family: super+comma dismiss, +SHIFT all, +SHIFT+ALT
  restore, +ALT restore+invoke, +CTRL+SHIFT dnd, super+N panel.
- NotificationContent.qml is the shared body renderer for toast + panel row
  (metaText = the panel's age label).