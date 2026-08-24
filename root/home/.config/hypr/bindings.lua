-- Key bindings.
-- Translated from bindings.conf (138 binds). Verified against the official
-- example/hyprland.lua, the Hyprland wiki, and the Lua dispatcher source
-- (src/config/lua/bindings/LuaBindingsDispatchers.cpp) on the main branch.
-- Key names are case-insensitive (xkb_keysym_from_name XKB_KEYSYM_CASE_INSENSITIVE).
-- Modifier order in the string does not matter; we use SUPER, then SHIFT,
-- CTRL, ALT, then the key, joined by " + ".

local mainMod = "SUPER"

-- Applications
hl.bind(mainMod .. " + Return",          hl.dsp.exec_cmd("uwsm app -- ghostty"))
hl.bind(mainMod .. " + SHIFT + F",       hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch uwsm app -- thunar"))
hl.bind(mainMod .. " + SHIFT + N",       hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ghostty -e nvim"))
hl.bind(mainMod .. " + SHIFT + G",       hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch uwsm app -- signal-desktop"))
hl.bind(mainMod .. " + SHIFT + M",       hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch uwsm app -- mpv"))
hl.bind(mainMod .. " + space",           hl.dsp.exec_cmd("hyprlauncher"))

-- Window switcher (fzf across all windows, floating)
hl.bind(mainMod .. " + slash",           hl.dsp.exec_cmd("~/.local/bin/hypr-window-switcher"))

-- Cheatsheet (keybindings list, floating)
hl.bind(mainMod .. " + C",               hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ghostty -e ~/.local/bin/hypr-keybinds"))

-- Night mode toggle
hl.bind(mainMod .. " + CTRL + N",        hl.dsp.exec_cmd("~/.local/bin/nightmode-toggle"))

-- Clipboard manager (floating)
hl.bind(mainMod .. " + CTRL + V",        hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ghostty -e ~/.local/bin/clipboard-manager"))

-- Waybar actions (all floating via hypr-float-launch)
hl.bind(mainMod .. " + SHIFT + A",       hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ghostty -e ~/.local/bin/calendar-tui"))
hl.bind(mainMod .. " + SHIFT + B",       hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ghostty -e bluetui"))
hl.bind(mainMod .. " + SHIFT + W",       hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ghostty -e impala"))
hl.bind(mainMod .. " + SHIFT + V",       hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ghostty -e wiremix"))
hl.bind(mainMod .. " + SHIFT + T",       hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ghostty -e btop"))
hl.bind(mainMod .. " + SHIFT + D",       hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ghostty -e ncdu /"))
hl.bind(mainMod .. " + SHIFT + P",       hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ~/.local/bin/power-mode-menu"))

-- Window management
hl.bind(mainMod .. " + W",               hl.dsp.window.close())
-- Close every window on the current workspace.
-- Was SUPER+CTRL+delete, which collided with the laptop display toggle at the
-- bottom of this file. Both registered the same combo, and the later one wins, so
-- this one never fired. Moved to SHIFT+CTRL+delete rather than displacing the
-- display toggle, which is the behaviour that combo actually had.
hl.bind(mainMod .. " + SHIFT + CTRL + delete", hl.dsp.exec_cmd("~/.local/bin/hypr-kill-workspace"))
hl.bind(mainMod .. " + F",               hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + CTRL + F",        hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + ALT + F",         hl.dsp.window.fullscreen({ mode = "fullscreen" }))
-- Super+T: toggle floating on the active window, applying the consistent
-- centered size (85%x90% of the focused monitor) when floating it.
hl.bind(mainMod .. " + T",               hl.dsp.exec_cmd("~/.local/bin/hypr-float-toggle"))
-- Super+E: toggle split direction (dwindle). Super+Shift+E: swap the two
-- halves of the current split.
hl.bind(mainMod .. " + E",               hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SHIFT + E",       hl.dsp.layout("swapsplit"))
hl.bind(mainMod .. " + P",               hl.dsp.window.pseudo())
hl.bind(mainMod .. " + O",               hl.dsp.window.pin())
hl.bind(mainMod .. " + G",               hl.dsp.group.toggle())
hl.bind(mainMod .. " + ALT + G",         hl.dsp.window.move({ out_of_group = true }))
hl.bind(mainMod .. " + ALT + Tab",       hl.dsp.group.next())
hl.bind(mainMod .. " + ALT + SHIFT + Tab", hl.dsp.group.prev())
hl.bind(mainMod .. " + S",               hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mainMod .. " + ALT + S",         hl.dsp.window.move({ workspace = "special:scratchpad" }))
hl.bind(mainMod .. " + SHIFT + ALT + S", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
hl.bind(mainMod .. " + CTRL + L",        hl.dsp.exec_cmd("uwsm app -- hyprlock"))
hl.bind(mainMod .. " + SHIFT + Escape",  hl.dsp.exec_cmd("uwsm stop"))

-- Toggle transparency
hl.bind(mainMod .. " + BackSpace", hl.dsp.exec_cmd(
    "hyprctl getoption decoration:active_opacity | grep -q '1.0' && hyprctl keyword decoration:active_opacity 0.97 && hyprctl keyword decoration:inactive_opacity 0.9 || hyprctl keyword decoration:active_opacity 1.0 && hyprctl keyword decoration:inactive_opacity 0.95"))

-- Toggle gaps
hl.bind(mainMod .. " + SHIFT + BackSpace", hl.dsp.exec_cmd(
    "hyprctl getoption general:gaps_in | grep -q '3' && hyprctl keyword general:gaps_in 0 && hyprctl keyword general:gaps_out 0 || hyprctl keyword general:gaps_in 3 && hyprctl keyword general:gaps_out 5"))

-- Cursor zoom
hl.bind(mainMod .. " + CTRL + Z", hl.dsp.exec_cmd(
    [[hyprctl keyword cursor:zoom_factor $(echo "$(hyprctl getoption cursor:zoom_factor | head -1 | awk '{print $2}') + 0.1" | bc)]]))
hl.bind(mainMod .. " + CTRL + ALT + Z", hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor 1.0"))

-- Toggles (idle, night mode)
hl.bind(mainMod .. " + CTRL + I", hl.dsp.exec_cmd(
    "hyprctl dispatch dpms off && hyprctl dispatch dpms on; pkill -u $(whoami) hypridle || uwsm app -- hypridle"))

-- Notifications (mako)
hl.bind(mainMod .. " + comma",            hl.dsp.exec_cmd("makoctl dismiss"))
hl.bind(mainMod .. " + SHIFT + comma",    hl.dsp.exec_cmd("makoctl dismiss --all"))
hl.bind(mainMod .. " + CTRL + comma",     hl.dsp.exec_cmd("makoctl restore"))
hl.bind(mainMod .. " + ALT + comma",      hl.dsp.exec_cmd("makoctl restore && makoctl invoke"))

-- DND toggle
hl.bind(mainMod .. " + CTRL + SHIFT + comma", hl.dsp.exec_cmd(
    "makoctl set-mode dnd || makoctl set-mode default"))

-- Waybar toggle
hl.bind(mainMod .. " + SHIFT + space",    hl.dsp.exec_cmd("pkill waybar || uwsm app -- waybar"))

-- Screenshots
hl.bind(mainMod .. " + SHIFT + S",        hl.dsp.exec_cmd("~/.local/bin/screenshot region"))
hl.bind("Print",                          hl.dsp.exec_cmd("~/.local/bin/screenshot full"))
hl.bind(mainMod .. " + Print",            hl.dsp.exec_cmd("~/.local/bin/screenshot window"))

-- Screen recording
hl.bind(mainMod .. " + SHIFT + R",        hl.dsp.exec_cmd("~/.local/bin/screencast"))

-- Focus (hjkl + arrows)
hl.bind(mainMod .. " + H",                hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L",                hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K",                hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J",                hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + left",             hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right",            hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",               hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",             hl.dsp.focus({ direction = "down" }))

-- Move windows
hl.bind(mainMod .. " + SHIFT + H",        hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L",        hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K",        hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J",        hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + left",     hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right",    hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",       hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",     hl.dsp.window.move({ direction = "down" }))

-- Resize (default) -- binde -> { repeating = true }
hl.bind(mainMod .. " + ALT + H",          hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + L",          hl.dsp.window.resize({ x = 20,  y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + K",          hl.dsp.window.resize({ x = 0,  y = -20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + J",          hl.dsp.window.resize({ x = 0,  y = 20,  relative = true }), { repeating = true })

-- Resize (fine)
hl.bind(mainMod .. " + CTRL + ALT + H",   hl.dsp.window.resize({ x = -5, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + ALT + L",   hl.dsp.window.resize({ x = 5,  y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + ALT + K",   hl.dsp.window.resize({ x = 0,  y = -5, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + ALT + J",   hl.dsp.window.resize({ x = 0,  y = 5,  relative = true }), { repeating = true })

-- Resize (coarse)
hl.bind(mainMod .. " + SHIFT + ALT + H",  hl.dsp.window.resize({ x = -60, y = 0,  relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + ALT + L",  hl.dsp.window.resize({ x = 60,  y = 0,  relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + ALT + K",  hl.dsp.window.resize({ x = 0,   y = -60, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + ALT + J",  hl.dsp.window.resize({ x = 0,   y = 60,  relative = true }), { repeating = true })

-- Workspace navigation
hl.bind(mainMod .. " + Tab",              hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + SHIFT + Tab",      hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + Tab",       hl.dsp.focus({ workspace = "previous" }))

-- Workspaces 1..10 (10 -> key 0)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,                 hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,         hl.dsp.window.move({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + ALT + " .. key,   hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Move workspace to monitor
hl.bind(mainMod .. " + SHIFT + ALT + left",  hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(mainMod .. " + SHIFT + ALT + right", hl.dsp.workspace.move({ monitor = "r" }))
hl.bind(mainMod .. " + SHIFT + ALT + up",    hl.dsp.workspace.move({ monitor = "u" }))
hl.bind(mainMod .. " + SHIFT + ALT + down",  hl.dsp.workspace.move({ monitor = "d" }))

-- Scroll workspaces (mouse wheel; NOT a mouse drag bind, so no { mouse = true })
-- NOTE: SUPER+mouse binds are broken by a Hyprland 0.55+ regression (PR #14633
-- aggregates modifier state across all keyboard devices on focus-enter, so
-- SUPER held on the real keyboard is overwritten by empty-mod devices). Use
-- the 3-finger touchpad swipe below as the primary mouse/touch path instead.
hl.bind(mainMod .. " + mouse_down",        hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",          hl.dsp.focus({ workspace = "e-1" }))

-- Touchpad gesture: 3-finger horizontal swipe switches workspaces (1:1 swipe,
-- like GNOME/KDE). Native Hyprland gesture support -- no plugin required. This
-- is the robust touchpad path: it bypasses both the SUPER+mouse mod-aggregation
-- regression and waybar's touchpad-emulated-scroll guard.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Mouse drag/resize (bindm -> { mouse = true })
hl.bind(mainMod .. " + mouse:272",         hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",         hl.dsp.window.resize(), { mouse = true })

-- Volume / brightness go through the media-keys wrapper. IMPORTANT: the path
-- must be explicit (~/.local/bin/media-keys) because Hyprland's exec PATH does
-- NOT include ~/.local/bin, so a bare "media-keys" is silently not found and
-- the key does nothing. No on-screen display: the state is shown live in the
-- waybar pulseaudio/backlight modules (icon + percent). Volume uses wpctl
-- (capped at 150%); brightness uses brightnessctl directly (swayosd gets it
-- wrong on this backlight -- raise no-ops, lower raises -- while returning
-- success). See root/home/.local/bin/media-keys for details.
hl.bind("XF86AudioRaiseVolume",            hl.dsp.exec_cmd("~/.local/bin/media-keys --output-volume raise"))
hl.bind("XF86AudioLowerVolume",            hl.dsp.exec_cmd("~/.local/bin/media-keys --output-volume lower"))
hl.bind("XF86AudioMute",                   hl.dsp.exec_cmd("~/.local/bin/media-keys --output-volume mute-toggle"))
hl.bind("ALT + XF86AudioRaiseVolume",      hl.dsp.exec_cmd("~/.local/bin/media-keys --output-volume raise 1"))
hl.bind("ALT + XF86AudioLowerVolume",      hl.dsp.exec_cmd("~/.local/bin/media-keys --output-volume lower 1"))
hl.bind("XF86AudioMicMute",                hl.dsp.exec_cmd("~/.local/bin/media-keys --input-volume mute-toggle"))
hl.bind("XF86AudioPlay",                   hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext",                   hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev",                   hl.dsp.exec_cmd("playerctl previous"))
hl.bind(mainMod .. " + XF86AudioMute", hl.dsp.exec_cmd(
    [[~/.local/bin/media-keys --output-volume mute-toggle && sleep 0.3 && pactl set-default-sink $(pactl list short sinks | grep -v "Monitor" | awk '{print $1}' |head -1)]]))

-- Brightness (brightnessctl direct via media-keys)
hl.bind("XF86MonBrightnessUp",             hl.dsp.exec_cmd("~/.local/bin/media-keys --brightness raise"))
hl.bind("XF86MonBrightnessDown",           hl.dsp.exec_cmd("~/.local/bin/media-keys --brightness lower"))
hl.bind("SHIFT + XF86MonBrightnessUp",     hl.dsp.exec_cmd("~/.local/bin/media-keys --brightness raise 100"))
hl.bind("SHIFT + XF86MonBrightnessDown",   hl.dsp.exec_cmd("~/.local/bin/media-keys --brightness lower 100"))

-- Keyboard backlight
hl.bind("XF86KbdBrightnessUp",             hl.dsp.exec_cmd("brightnessctl -d *::kbd_backlight set +10%"))
hl.bind("XF86KbdBrightnessDown",           hl.dsp.exec_cmd("brightnessctl -d *::kbd_backlight set 10%-"))

-- Touchpad toggle
hl.bind("XF86TouchpadToggle", hl.dsp.exec_cmd(
    "~/.local/bin/toggle-touchpad || hyprctl keyword input:touchpad:enabled $(hyprctl getoption input:touchpad:enabled | awk '{print $2}') | grep -q true && hyprctl keyword input:touchpad:enabled false || hyprctl keyword input:touchpad:enabled true"))

-- Laptop lid close/open is handled by hypridle - see hypridle.conf

-- Laptop display toggle
hl.bind(mainMod .. " + CTRL + delete",     hl.dsp.exec_cmd("~/.local/bin/hypr-toggle-display"))
