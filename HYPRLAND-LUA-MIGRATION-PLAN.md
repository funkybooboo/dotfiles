# Hyprland: hyprlang -> Lua config migration plan

Status: PLANNED, not started. Do this on a quiet machine with no other work
running. Estimated effort: half a day. Risk: medium (138 binds + many
sections; one typo can drop keybinds until reverted).

## Why

Since Hyprland 0.55 the hyprlang config format is deprecated, and on 0.56.2
(what this machine runs) ALL hyprlang window rules are dead: the v1 bracket
form `windowrule[ACTION] = matcher` parses without error but NEVER applies, and
`windowrulev2 = ...` is removed outright (it now raises a config error and does
nothing). This was verified live with `hyprctl`:

- `windowrule[float] = ^(thunar|Thunar)$` + a launched thunar ->
  `hyprctl clients` showed `floating: false`. v1 rules are no-ops.
- `hyprctl eval` (Lua at runtime) returns "eval is only supported with the lua
  config manager" -- blocked while `hyprland.conf` is active.
- A `hyprland.lua` file is IGNORED entirely while `hyprland.conf` exists
  (verified: an intentionally-broken `hyprland.lua` produced zero configerrors,
  binds count unchanged at 138).

Consequence: every window rule in `windows.conf` (opacity multipliers, float
for mpv/pavucontrol/imv, the nofocus XWayland rule, the thunar/signal/
nwg-displays float rules, the hypr-float-title rule, the input.conf
scroll_touchpad rules) has silently NOT applied since the 0.55 upgrade. The
float-launch helper script `hypr-float-apply` has been doing all floating
~0.15s after a window maps, which is the "starts tiled then goes floating"
flash the user dislikes. The dead `windowrulev2` lines also caused a red error
banner at the top of the screen (fixed this session by reverting them).

The ONLY way to get creation-time window rules (zero flash) is to switch the
active config to `~/.config/hypr/hyprland.lua` (the Lua config manager). That
requires migrating the ENTIRE config, because hyprlang and Lua configs do not
coexist -- it is one or the other.

## Goal

One `~/.config/hypr/hyprland.lua` (plus `require`d modules) that reproduces the
current hyprlang config exactly, then adds the float-at-creation window rules
so keybind/waybar-launched apps open floating with no tile-then-float flash.
Also restores all the other dead window rules (opacity, mpv/pavucontrol/imv
float, scroll_touchpad, etc.) as a bonus.

## Constraints to preserve (user-verified behavior)

- Super+Enter (`uwsm app -- ghostty`) -> TILED. Do not float.
- Super+Space -> hyprlauncher -> TILED. Do not float.
- Apps launched FROM hyprlauncher -> tiled (they get no `hypr-float` title
  marker, so they do not match the float rule). Exception: the global
  class-based rules for thunar/signal/mpv/nwg-displays will float those even
  from hyprlauncher (pre-existing behavior the user has not objected to; keep).
- Super+T = `hypr-float-toggle` (toggle floating on the active window,
  applying the 85%x90% centered size). Keep the script; it still works as a
  dispatcher-based floater for manually-floated windows.

## Scope -- files to migrate

Current hyprlang config tree (`~/.config/hypr/`):

- `hyprland.conf`        -- just `source = ...` lines (becomes hyprland.lua)
- `monitors.conf`        -- `monitor=...` lines (nwg-displays generated)
- `env.conf`             -- `env = K,V`
- `autostart.conf`       -- `exec-once = ...` and one plain `exec =`
- `input.conf`           -- `input { touchpad{} }`, `misc{}`, `device{}`, plus
                            two dead `windowrule = match:class ...` lines
- `looknfeel.conf`       -- general/dwindle/master/group{groupbar{}}/
                            decoration{blur{} shadow{}}/animations{}/cursor{}/
                            binds{}/misc{}/ecosystem{}
- `windows.conf`         -- all window rules (dead today)
- `bindings.conf`        -- ~138 binds (bind/binde/bindm, incl. mouse + bare-key)
- `workspaces.conf`      -- empty (nothing to migrate)

Helper scripts that are NOT config and stay as-is: `hypr-float-apply`,
`hypr-float-launch`, `hypr-float-toggle`, `hypr-window-switcher`,
`hypr-window-switcher-inner`, `power-menu`, `power-mode-menu`,
`set-wallpaper.sh`, `monitor-watcher.sh`. (After migration, the float rules
apply at creation so `hypr-float-launch`'s post-detection apply becomes a
fallback only; optionally simplify it later.)

## Target structure

Mirror the current file split as Lua modules required from `hyprland.lua`:

```
~/.config/hypr/
  hyprland.lua          -- entry: requires the modules below, in the same
                          order hyprland.conf currently sources them
  lua/monitors.lua       -- was monitors.conf   (hl.monitor)
  lua/env.lua            -- was env.conf        (hl.env)
  lua/autostart.lua      -- was autostart.conf   (hl.on hyprland.start)
  lua/input.lua          -- was input.conf      (hl.config input/misc + hl.device)
  lua/looknfeel.lua      -- was looknfeel.conf   (hl.config general/dwindle/...)
  lua/windows.lua        -- was windows.conf     (hl.window_rule)
  lua/bindings.lua       -- was bindings.conf    (hl.bind)
  lua/workspaces.lua     -- was workspaces.conf  (empty / hl.workspace_rule)
```

`hyprland.lua`:
```lua
-- Entry point. Order matches the old hyprland.conf `source` order.
require("lua/monitors")
require("lua/env")
require("lua/autostart")
require("lua/input")
require("lua/looknfeel")
require("lua/windows")
require("lua/bindings")
require("lua/workspaces")
```
(Use `require("lua/monitors")` -- relative to $XDG_CONFIG_HOME/hypr. The wiki
allows `/` or `.` as separator.)

## hyprlang -> Lua API mapping

Confirmed from the wiki + `example/hyprland.lua` (grab once for reference:
`curl -sL https://raw.githubusercontent.com/hyprwm/Hyprland/main/example/hyprland.lua`).

### Variables / sections
| hyprlang | Lua |
| --- | --- |
| `general { gaps_in = 3 }` | `hl.config({ general = { gaps_in = 3 } })` |
| nested: `decoration { blur { size = 6 } }` | `hl.config({ decoration = { blur = { size = 6 } } })` |
| `col.active_border = rgba(cba6f7ff)` | `hl.config({ general = { col = { active_border = "rgba(cba6f7ff)" } } })` |
| `group { groupbar { col.active = ... } }` | `hl.config({ group = { groupbar = { col = { active = "rgba(cba6f7ff)" } } } })` |

`hl.config({...})` can be called many times; nest sub-sections as tables.

### Animations
| hyprlang | Lua |
| --- | --- |
| `bezier = easeOutQuint, 0.23, 1, 0.32, 1` | `hl.curve("easeOutQuint", { type="bezier", points={{0.23,1},{0.32,1}} })` |
| `animation = windows, 1, 3, easeOutQuint, popin 87%` | `hl.animation({ leaf="windows", enabled=true, speed=3, bezier="easeOutQuint", style="popin 87%" })` |
| `animation = workspaces, 1, 3, easeOutQuint` | `hl.animation({ leaf="workspaces", enabled=true, speed=3, bezier="easeOutQuint" })` |

NOTE: the example lua uses `speed` differently (it appears to be 1/ the
hyprlang "duration" value). The current config uses hyprlang values
(`windows, 1, 3, ...` -> speed=3). Keep the hyprlang numbers first and
visually compare the result after migration; tweak if the animation feels off.

### Monitors / devices / env / autostart
| hyprlang | Lua |
| --- | --- |
| `monitor=eDP-1,2256x1504@60.0,3754x1917,1.33` | `hl.monitor({ output="eDP-1", mode="2256x1504@60.0", position="3754x1917", scale=1.33 })` |
| `env = XCURSOR_SIZE,24` | `hl.env("XCURSOR_SIZE", "24")` |
| `device { name = foo; sensitivity = 0.2 }` | `hl.device({ name="foo", sensitivity=0.2 })` |
| `exec-once = cmd` | `hl.on("hyprland.start", function() hl.exec_cmd("cmd") end)` |
| plain `exec = cmd` (re-fires on reload) | CONFIRM: likely `hl.exec_cmd` in a reload hook, or `hl.on("config.reloaded", ...)`. The only plain `exec` is `pgrep -x swayosd-server || uwsm app -- swayosd-server`. If no clean equivalent, keep it as an `exec-once` + accept that a second swayosd won't spawn on reload (the pgrep guard already prevents duplicates). |

### Binds
| hyprlang | Lua |
| --- | --- |
| `$mod = SUPER` | `local mainMod = "SUPER"` |
| `bind = $mod, Return, exec, uwsm app -- ghostty` | `hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("uwsm app -- ghostty"))` |
| `bind = $mod SHIFT, F, exec, ~/.local/bin/hypr-float-launch uwsm app -- thunar` | `hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch uwsm app -- thunar"))` |
| `bind = $mod, H, movefocus, l` | `hl.bind(mainMod .. " + H", hl.dsp.move_focus("left"))` -- CONFIRM dispatcher name/args from the Binds wiki |
| `binde = $mod ALT, H, resizeactive, -20 0` | `hl.bind(mainMod .. " + ALT + H", hl.dsp.resize_active("-20 0"), { repeat = true })` -- CONFIRM |
| `bindm = $mod, mouse:272, movewindow` | `hl.bind(mainMod .. " + mouse:272", hl.dsp.window.move(), { mouse = true })` |
| `bind = , Print, exec, ...` (no mod) | `hl.bind("Print", hl.dsp.exec_cmd(...))` -- CONFIRM empty-mod form |
| `bind = $mod CTRL, delete, exec, ...` (key name `delete`) | use `Delete`? CONFIRM key naming |

CRITICAL: the dispatcher API (`hl.dsp.*`) names/args are NOT fully known from
the example alone. Before writing bindings.lua, fetch the Binds wiki page and
map EVERY dispatcher used in bindings.conf. Dispatchers currently used:
exec, movefocus, movewindow, resizewindow, resizeactive, killactive,
fullscreen, layoutmsg (togglesplit/swapsplit), pseudo, pin, togglegroup,
moveoutofgroup, changegroupactive, togglespecialworkspace, movetoworkspace,
workspace, movecurrentworkspacetomonitor, togglefloating, setfloating,
centerwindow, resizewindowpixel, focuswindow, dpms, kill, exit/stop. Many of
these have obvious `hl.dsp.<thing>` wrappers; for any that do not, there is
likely a generic `hl.dsp` escape hatch (the example uses
`hyprctl dispatch 'hl.dsp.exit()'` style strings) -- confirm on the wiki.

### Window rules (the payoff)
| hyprlang (dead) | Lua (works) |
| --- | --- |
| `windowrule[float] = initialTitle:^(hypr-float.*)$` | `hl.window_rule({ match={ initial_title="^(hypr-float.*)$" }, float=true })` |
| `windowrule[size 85% 90%] = initialTitle:...` | `size={ "monitor_w * 0.85", "monitor_h * 0.90" }` (effect on the same rule) |
| `windowrule[move 50% 50%] = ..., center` | `center=true` (effect on the same rule) |
| `windowrule[opacity 0.97 0.9] = tag:default-opacity` | `hl.window_rule({ match={ tag="default-opacity" }, opacity="0.97 0.9" })` + a `hl.window_rule({ match={ class=".*" }, tag="+default-opacity" })` to set the tag |
| `windowrule[suppress_event maximize] = class:.*` | `hl.window_rule({ match={ class=".*" }, suppress_event="maximize" })` |
| `windowrule[nofocus] = class:^$, title:^$, xwayland:1, ...` | `hl.window_rule({ match={ class="^$", title="^$", xwayland=true, float=true, fullscreen=false, pin=false }, no_focus=true })` |
| `windowrule = match:class com.mitchellh.ghostty, scroll_touchpad 0.2` (input.conf) | `hl.window_rule({ match={ class="com.mitchellh.ghostty" }, scroll_touchpad=0.2 })` |

Match fields (props): class, title, initial_class, initial_title, tag,
xwayland, float, fullscreen, pin, focus, group, modal, workspace, content,
xdg_tag. Effects include: float, tile, size, center, move, opacity, tag,
suppress_event, no_focus, no_anim, idle_inhibit, workspace, monitor, pin,
pseudo, border_size, rounding, etc.

## The float rules to add (the actual flash fix)

Put these in `lua/windows.lua`. They make hypr-float-launch windows float +
size + center AT CREATION (zero flash), and replace the post-detection
hypr-float-apply resizing for the matched apps.

```lua
-- Ghostty windows launched by hypr-float-launch get --title=hypr-float-<pid>
-- (the launch script injects it). Float+size+center at creation -> no flash.
-- Normal Super+Enter ghostty and hyprlauncher-launched apps keep the default
-- title and stay tiled.
hl.window_rule({
    name   = "float-launch-ghostty",
    match  = { initial_title = "^(hypr-float.*)$" },
    float  = true,
    size   = { "monitor_w * 0.85", "monitor_h * 0.90" },
    center = true,
})

-- Non-ghostty GUI apps launched by hypr-float-launch keybinds / waybar icons.
-- These can't carry the hypr-float title, so match by initial_class.
hl.window_rule({ name = "float-launch-thunar",        match = { initial_class = "^(thunar)$" },        float = true, size = { "monitor_w * 0.85", "monitor_h * 0.90" }, center = true })
hl.window_rule({ name = "float-launch-signal",        match = { initial_class = "^(Signal|signal)$" }, float = true, size = { "monitor_w * 0.85", "monitor_h * 0.90" }, center = true })
hl.window_rule({ name = "float-launch-nwg-displays",  match = { initial_class = "^(nwg-displays)$" },  float = true, size = { "monitor_w * 0.85", "monitor_h * 0.90" }, center = true })

-- mpv: always floating + centered.
hl.window_rule({ name = "mpv-float", match = { class = "^(mpv)$" }, float = true, size = { "monitor_w * 0.85", "monitor_h * 0.90" }, center = true })
```

Also port the rest of windows.conf (imv float+size+center, pavucontrol,
blueman-manager, the Open|Save|File|Folder dialogs, the
`title:^(is sharing your screen)$ -> workspace special silent` rule, the
opacity rules + default-opacity tag, the noidle tags for mpv/zoom, the
suppress_event maximize rule, the nofocus XWayland rule).

## Procedure (do on a quiet machine, at a real TTY, with this checklist)

0. Pre-flight:
   - Save the current working tree: `cd ~/dotfiles && git stash` (or commit)
     so uncommitted prior-session changes are safe.
   - `cp -a ~/.config/hypr ~/.config/hypr.bak` so the live hyprlang config is
     recoverable even if dotfiles symlinks get rewired.
   - Be at a TTY (Ctrl+Alt+F2) or have a second machine with SSH, in case the
     graphical session loses keybinds mid-migration.
   - Have `hyprctl` reachable from another terminal the whole time.

1. Write the Lua modules WITHOUT activating them. Create `lua/*.lua` files
   translating each `.conf` in the order above. Do NOT create/rename
   `hyprland.lua` yet, so the live config stays hyprlang and the machine keeps
   working while you write.

2. Validate Lua syntax offline: `luajit -blua/*.lua` or `lua -e` load tests
   (Hyprland bundles luajit; if neither cli tool is installed, `pacman -S
   luajit` or skip and rely on `hyprctl configerrors` later).

3. Create `~/.config/hypr/hyprland.lua` (the entry that requires the modules).
   This does NOT activate yet -- hyprland.lua is ignored while hyprland.conf
   exists. Good: you can iterate on the file without affecting the live
   session.

4. Smoke-test WITHOUT going live: temporarily rename
   `~/.config/hypr/hyprland.conf` -> `hyprland.conf.disabled`, then
   `hyprctl reload config-only`, then immediately run the checks in step 5,
   then RESTORE the name and `hyprctl reload`. (`config-only` avoids
   re-applying monitor config so screens do not rearrange during the test.)
   If anything is wrong, restoring the .conf name + reload brings the working
   hyprlang config back in seconds.

5. Checks after each test reload:
   - `hyprctl configerrors` -- must be empty.
   - `hyprctl binds | grep -c '^bind'` -- must be ~138 (same as today).
   - `hyprctl getoption general:gaps_in` / `decoration:rounding` /
     `animations:enabled` -- values match the current config.
   - Launch a float app (`hypr-float-launch ghostty -e btop`) and confirm
     `hyprctl clients` shows `floating: true` + size 85%x90% + centered
     IMMEDIATELY (no detect delay). This is the flash-fix proof.
   - Launch `uwsm app -- ghostty` (Super+Enter path) -> `floating: false`
     (still tiled). Launch hyprlauncher -> tiled.

6. Once all checks pass at the smoke-test stage, go live permanently:
   - Move `hyprland.conf` out of the way for real:
     `mv ~/.config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf.disabled`
     (keep it as an in-place backup; do not delete).
   - `hyprctl reload` (full reload this time, so monitors + everything apply).
   - Re-run all step-5 checks. Press every Super bind category to confirm.

7. Wire the dotfiles: in `root/home/.config/hypr/` the tracked files become
   `hyprland.lua` + `lua/*.lua`. The old `*.conf` files (except the
   machine-local gitignored ones: `monitors.conf`, `workspaces.conf`,
   `hyprpaper.conf`) are removed from the tree. Add a migration
   `migrations/NNNNNN-hyprland-lua.sh` that symlinks the new lua files and
   removes the old .conf symlinks (idempotent, non-fatal). Number it after
   000310 (the existing hyprland migration). Update `README.md` migration
   table + count.

8. Commit + push. Re-run `./migrate.sh` on other machines to converge.

## Rollback (at any point)

- Fast, live: `mv ~/.config/hypr/hyprland.conf.disabled ~/.config/hypr/hyprland.conf`
  && `rm -f ~/.config/hypr/hyprland.lua` && `hyprctl reload`.
- Full: `rm -rf ~/.config/hypr && cp -a ~/.config/hypr.bak ~/.config/hypr &&
  hyprctl reload`.
- Dotfiles: `git checkout` the migration + `git revert` the commit.

## Risks / open questions to resolve while writing (confirm from wiki)

- Dispatcher API: full `hl.dsp.*` list + arg shapes for movefocus,
  resizeactive, layoutmsg, movetoworkspace, workspace, togglespecialworkspace,
  movecurrentworkspacetomonitor, togglefloating/setfloating, centerwindow,
  resizewindowpixel, focuswindow, dpms, kill, killactive, fullscreen, pseudo,
  pin, togglegroup, moveoutofgroup, changegroupactive. Fetch the Binds wiki
  page and map each before writing bindings.lua (it is the biggest file).
- `binde` (repeat-on-hold) and `bindm` (mouse) option shapes -- confirm
  `{ repeat = true }` and `{ mouse = true }` from the wiki.
- Bare-modifier binds (`bind = , Print, ...`) and key name spelling
  (`delete` vs `Delete`, XF86 keys, comma) in the Lua mod string.
- `speed` units in `hl.animation` vs hyprlang `animation = name, enabled,
  duration, curve, style` -- may need conversion.
- Plain `exec =` (re-fire on reload) equivalent for the swayosd guard line.
- Whether `hl.window_rule` `size` expressions use `monitor_w`/`monitor_h`
  (the example shows `size = {"monitor_w * 0.5", "monitor_h * 0.5"}` -- yes).
- After migration, `hypr-float-launch`'s post-detection apply can be reduced to
  a fallback (only float+size+center windows that no rule matched), since the
  rules now handle it at creation. Optional cleanup, not required.

## Testing checklist (sign-off before declaring done)

- [ ] `hyprctl configerrors` empty
- [ ] `hyprctl binds | grep -c '^bind'` == 138 (same count)
- [ ] gaps/rounding/opacity/animations match old config via `hyprctl getoption`
- [ ] Super+Enter -> tiled ghostty
- [ ] Super+Space -> tiled hyprlauncher
- [ ] Super+Shift+F (thunar) -> floating, 85%x90%, centered, NO tile flash
- [ ] Super+Shift+T (btop, ghostty-based) -> floating, no flash
- [ ] Super+Shift+N -> floating ghostty running nvim
- [ ] Waybar cpu/memory/disk/bluetooth/network icons -> floating, no flash
- [ ] Super+T toggles floating on an existing tiled window (still works)
- [ ] Super+C (keybind cheatsheet) floating
- [ ] power menu (waybar power button) floating
- [ ] mpv -> floating centered
- [ ] opacity rules visibly applied (mpv/vlc/firefox opaque, others 0.97/0.9)
- [ ] scroll_touchpad 0.2 on ghostty feels right
- [ ] no config error banner at top of screen
- [ ] `git status` clean after committing; `./migrate.sh` idempotent re-run ok
