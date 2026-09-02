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
  MUST be a Lua expression. `hyprctl eval '<lua>'` for top-level (hl.monitor
  etc.). `hyprctl keyword` is GONE in Lua mode.
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