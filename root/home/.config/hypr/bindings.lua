-- Key bindings.
--
-- Every bind passes { description = ... } so it carries a label. That
-- description is the ONLY place a keybinding is explained: the Super+C
-- cheatsheet and docs/keybindings.md are both rendered from it, so a rebind
-- cannot leave a stale label behind. The "Category:" prefix is what groups them.
--
-- One key carries one idea, and every binding for that idea uses that key. So S is
-- the scratchpad and nothing else, C is screen capture, G is tab groups, Tab is
-- workspace navigation, Escape is session and power.
--
-- SUPER + CTRL + <letter> is reserved entirely for launching apps. That is what
-- lets C mean capture while SUPER+CTRL+C stays free for an app: the namespace is
-- separate, so the two never compete. Nothing else may live there.
--
-- Three groups carry a family rather than a single action, deliberately. hjkl is
-- one directional idea escalating by modifier (SUPER focus, +SHIFT move, +ALT
-- resize, +ALT+SHIFT resize far). The arrows escalate by scope instead (SUPER
-- focus, +SHIFT the window, +SHIFT+ALT the whole workspace onto that monitor).
-- BackSpace holds the runtime appearance toggles.
--
-- No binding may depend on a key this keyboard lacks, which rules out Print.
--
-- Key names are case-insensitive (xkb_keysym_from_name XKB_KEYSYM_CASE_INSENSITIVE).
-- Modifier order in the string does not matter; we use SUPER, then SHIFT, CTRL,
-- ALT, then the key, joined by " + ".

local mainMod = "SUPER"

-- Applications. Utility windows go through hypr-float-launch, which floats and
-- centres them at 85%x90% of the focused monitor; for ghostty it sets a
-- hypr-float-<pid> title so the windows.lua rule floats them at creation.
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("uwsm app -- ghostty"),
    { description = "Apps: Terminal" })
-- herdr attaches to its own persistent server, so this lands in the existing
-- session rather than starting a fresh shell. Tiled like a plain ghostty, not
-- floated: it is a workspace to work in, not a utility popup.
hl.bind(mainMod .. " + CTRL + Return", hl.dsp.exec_cmd("uwsm app -- ghostty -e herdr"),
    { description = "Apps: Terminal running herdr" })
hl.bind(mainMod .. " + CTRL + F", hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch uwsm app -- thunar"),
    { description = "Apps: File manager" })
hl.bind(mainMod .. " + CTRL + Y", hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ghostty -e fish -c y"),
    { description = "Apps: File manager in a terminal" })
hl.bind(mainMod .. " + CTRL + N", hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ghostty -e nvim"),
    { description = "Apps: Editor" })
hl.bind(mainMod .. " + CTRL + M", hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch uwsm app -- mpv"),
    { description = "Apps: Media player" })
hl.bind(mainMod .. " + CTRL + G", hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch uwsm app -- signal-desktop"),
    { description = "Apps: Signal" })
hl.bind(mainMod .. " + CTRL + A", hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ghostty -e ~/.local/bin/calendar-tui"),
    { description = "Apps: Calendar" })
hl.bind(mainMod .. " + CTRL + B", hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ghostty -e bluetui"),
    { description = "Apps: Bluetooth manager" })
-- impala manages wifi through NetworkManager (000402 runs NM with the iwd
-- backend, so saved networks in /var/lib/iwd keep connecting).
hl.bind(mainMod .. " + CTRL + W", hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ghostty -e impala"),
    { description = "Apps: Wi-Fi manager" })
hl.bind(mainMod .. " + CTRL + V", hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ghostty -e wiremix"),
    { description = "Apps: Audio mixer" })
hl.bind(mainMod .. " + CTRL + T", hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ghostty -e btop"),
    { description = "Apps: System monitor" })
hl.bind(mainMod .. " + CTRL + D", hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ghostty -e ncdu /"),
    { description = "Apps: Disk usage" })
hl.bind(mainMod .. " + CTRL + P", hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ~/.local/bin/power-mode-menu"),
    { description = "Apps: Power profile menu" })

-- Shell surfaces
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("quickshell ipc call shell launcher"),
    { description = "Shell: Application launcher" })
hl.bind(mainMod .. " + slash", hl.dsp.exec_cmd("quickshell ipc call shell switcher"),
    { description = "Shell: Window switcher" })
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("quickshell ipc call shell clipboard"),
    { description = "Shell: Clipboard history" })
-- On SUPER+? because that is the help key everywhere else. It shares `slash` with
-- the switcher on purpose: one finds windows, the other finds keys.
hl.bind(mainMod .. " + SHIFT + slash",
    hl.dsp.exec_cmd("~/.local/bin/hypr-float-launch ghostty -e ~/.local/bin/hypr-keybinds"),
    { description = "Shell: Keybinding cheatsheet" })

-- Notifications
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd("quickshell ipc call shell dismiss"),
    { description = "Shell: Dismiss the newest notification" })
hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.exec_cmd("quickshell ipc call shell dismissAll"),
    { description = "Shell: Dismiss all notifications" })
hl.bind(mainMod .. " + SHIFT + ALT + comma", hl.dsp.exec_cmd("quickshell ipc call shell restore"),
    { description = "Shell: Restore the last notification" })
hl.bind(mainMod .. " + ALT + comma",
    hl.dsp.exec_cmd("quickshell ipc call shell restore && quickshell ipc call shell invoke"),
    { description = "Shell: Restore and activate the last notification" })
hl.bind(mainMod .. " + CTRL + SHIFT + comma", hl.dsp.exec_cmd("quickshell ipc call shell dnd"),
    { description = "Shell: Toggle do not disturb" })

-- Window management
hl.bind(mainMod .. " + W", hl.dsp.window.close(),
    { description = "Window: Close" })
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen(),
    { description = "Window: Toggle fullscreen" })
hl.bind(mainMod .. " + ALT + F", hl.dsp.window.fullscreen({ mode = "maximized" }),
    { description = "Window: Toggle maximize" })
-- Toggles floating via the script rather than the dispatcher, so a floated
-- window gets the same 85%x90% centred geometry as one launched floating.
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("~/.local/bin/hypr-float-toggle"),
    { description = "Window: Toggle floating" })
-- Without these the layout tree cannot be steered at all: looknfeel.lua sets
-- force_split = 2, so every new window lands right/below regardless of cursor
-- position, and preserve_split = true makes that orientation stick.
hl.bind(mainMod .. " + E", hl.dsp.layout("togglesplit"),
    { description = "Window: Flip the split direction" })
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.layout("swapsplit"),
    { description = "Window: Swap the two halves of the split" })
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo(),
    { description = "Window: Toggle pseudotiling" })
hl.bind(mainMod .. " + O", hl.dsp.window.pin(),
    { description = "Window: Pin above all workspaces" })
hl.bind(mainMod .. " + G", hl.dsp.group.toggle(),
    { description = "Window: Toggle tab group" })
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.window.move({ out_of_group = true }),
    { description = "Window: Move out of the tab group" })
hl.bind(mainMod .. " + ALT + G", hl.dsp.group.next(),
    { description = "Window: Next tab in the group" })
hl.bind(mainMod .. " + ALT + SHIFT + G", hl.dsp.group.prev(),
    { description = "Window: Previous tab in the group" })

-- These three still shell out to `hyprctl keyword`, which does not exist in Lua
-- config mode -- they are inert here until rewritten against the Lua config API
-- and verified on this machine.
hl.bind(mainMod .. " + BackSpace", hl.dsp.exec_cmd(
    "hyprctl getoption decoration:active_opacity | grep -q '1.0' && hyprctl keyword decoration:active_opacity 0.97 && hyprctl keyword decoration:inactive_opacity 0.9 || hyprctl keyword decoration:active_opacity 1.0 && hyprctl keyword decoration:inactive_opacity 0.95"),
    { description = "Window: Toggle transparency" })
hl.bind(mainMod .. " + ALT + BackSpace", hl.dsp.exec_cmd(
    "hyprctl getoption general:gaps_in | grep -q '3' && hyprctl keyword general:gaps_in 0 && hyprctl keyword general:gaps_out 0 || hyprctl keyword general:gaps_in 3 && hyprctl keyword general:gaps_out 5"),
    { description = "Window: Toggle gaps" })

-- Scratchpad
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("scratchpad"),
    { description = "Workspace: Toggle the scratchpad" })
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }),
    { description = "Workspace: Move window to the scratchpad" })
hl.bind(mainMod .. " + SHIFT + ALT + S",
    hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }),
    { description = "Workspace: Move window to the scratchpad without following" })

-- Session and system
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("uwsm app -- hyprlock"),
    { description = "System: Lock the screen" })
-- Deliberately the old log-out chord: habit now lands on a menu that prompts
-- rather than ending the session outright.
hl.bind(mainMod .. " + SHIFT + Escape", hl.dsp.exec_cmd("~/.local/bin/power-menu"),
    { description = "System: Power menu" })
hl.bind(mainMod .. " + CTRL + SHIFT + Escape", hl.dsp.exec_cmd("uwsm stop"),
    { description = "System: Log out" })
hl.bind(mainMod .. " + CTRL + SHIFT + N", hl.dsp.exec_cmd("~/.local/bin/nightmode-toggle"),
    { description = "System: Toggle night mode" })
hl.bind(mainMod .. " + CTRL + SHIFT + I", hl.dsp.exec_cmd("~/.local/bin/keepawake-toggle --wake"),
    { description = "System: Toggle keep-awake and wake the displays" })
hl.bind(mainMod .. " + CTRL + SHIFT + D", hl.dsp.exec_cmd("~/.local/bin/hypr-toggle-display"),
    { description = "System: Toggle the laptop display" })
hl.bind(mainMod .. " + CTRL + SHIFT + delete", hl.dsp.exec_cmd("~/.local/bin/hypr-kill-workspace"),
    { description = "System: Close every window on this workspace" })
hl.bind(mainMod .. " + CTRL + SHIFT + Q", hl.dsp.exec_cmd("pkill -x quickshell; uwsm app -- quickshell"),
    { description = "System: Restart the shell" })
hl.bind("XF86TouchpadToggle", hl.dsp.exec_cmd("~/.local/bin/toggle-touchpad"),
    { description = "System: Toggle the touchpad" })

-- Cursor magnifier, on the zoom cluster every browser and editor uses. No reset
-- bind: 0 belongs to workspace 10, and repeated zoom-out reaches 1.0 anyway. Same
-- Lua-mode caveat as the two toggles above: `hyprctl keyword` is inert here.
hl.bind(mainMod .. " + ALT + equal", hl.dsp.exec_cmd(
    [[hyprctl keyword cursor:zoom_factor $(echo "$(hyprctl getoption cursor:zoom_factor | head -1 | awk '{print $2}') + 0.1" | bc)]]),
    { description = "Resize: Zoom the cursor in", repeating = true })
hl.bind(mainMod .. " + ALT + minus", hl.dsp.exec_cmd(
    [[hyprctl keyword cursor:zoom_factor $(echo "$(hyprctl getoption cursor:zoom_factor | head -1 | awk '{print $2}') - 0.1" | bc)]]),
    { description = "Resize: Zoom the cursor out", repeating = true })

-- Capture. On C rather than Print because this keyboard has no Print key. Region
-- takes the bare chord since it is the common case.
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("~/.local/bin/screenshot region"),
    { description = "Capture: Screenshot a region" })
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("~/.local/bin/screenshot window"),
    { description = "Capture: Screenshot the active window" })
hl.bind(mainMod .. " + ALT + C", hl.dsp.exec_cmd("~/.local/bin/screenshot full"),
    { description = "Capture: Screenshot the whole output" })
hl.bind(mainMod .. " + CTRL + SHIFT + C", hl.dsp.exec_cmd("~/.local/bin/hypr-ocr"),
    { description = "Capture: Region OCR to the clipboard" })
-- Video gets its own key: a recording is a toggle with a duration, not a still.
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("~/.local/bin/screencast"),
    { description = "Capture: Toggle screen recording" })

-- Focus
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }), { description = "Focus: Left" })
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }), { description = "Focus: Right" })
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }), { description = "Focus: Up" })
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }), { description = "Focus: Down" })
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }), { description = "Focus: Left" })
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "Focus: Right" })
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }), { description = "Focus: Up" })
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }), { description = "Focus: Down" })

-- Move the window
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }), { description = "Window: Move left" })
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }), { description = "Window: Move right" })
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }), { description = "Window: Move up" })
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }), { description = "Window: Move down" })
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }), { description = "Window: Move left" })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }), { description = "Window: Move right" })
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }), { description = "Window: Move up" })
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }), { description = "Window: Move down" })

-- Resize. Two steps rather than three: the old 5px tier sat on its own modifier
-- and never earned it.
hl.bind(mainMod .. " + ALT + H", hl.dsp.window.resize({ x = -20, y = 0, relative = true }),
    { description = "Resize: Shrink horizontally", repeating = true })
hl.bind(mainMod .. " + ALT + L", hl.dsp.window.resize({ x = 20, y = 0, relative = true }),
    { description = "Resize: Grow horizontally", repeating = true })
hl.bind(mainMod .. " + ALT + K", hl.dsp.window.resize({ x = 0, y = -20, relative = true }),
    { description = "Resize: Shrink vertically", repeating = true })
hl.bind(mainMod .. " + ALT + J", hl.dsp.window.resize({ x = 0, y = 20, relative = true }),
    { description = "Resize: Grow vertically", repeating = true })
hl.bind(mainMod .. " + SHIFT + ALT + H", hl.dsp.window.resize({ x = -60, y = 0, relative = true }),
    { description = "Resize: Shrink horizontally by a lot", repeating = true })
hl.bind(mainMod .. " + SHIFT + ALT + L", hl.dsp.window.resize({ x = 60, y = 0, relative = true }),
    { description = "Resize: Grow horizontally by a lot", repeating = true })
hl.bind(mainMod .. " + SHIFT + ALT + K", hl.dsp.window.resize({ x = 0, y = -60, relative = true }),
    { description = "Resize: Shrink vertically by a lot", repeating = true })
hl.bind(mainMod .. " + SHIFT + ALT + J", hl.dsp.window.resize({ x = 0, y = 60, relative = true }),
    { description = "Resize: Grow vertically by a lot", repeating = true })

-- Workspace navigation
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "e+1" }), { description = "Workspace: Next" })
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "e-1" }), { description = "Workspace: Previous" })
hl.bind(mainMod .. " + ALT + Tab", hl.dsp.focus({ workspace = "previous" }), { description = "Workspace: Last used" })

-- Workspaces 1..10 (10 -> key 0)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }),
        { description = "Workspace: Go to " .. i })
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }),
        { description = "Workspace: Move window to " .. i })
    hl.bind(mainMod .. " + SHIFT + ALT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }),
        { description = "Workspace: Move window to " .. i .. " without following" })
end

-- Move the whole workspace to another monitor
hl.bind(mainMod .. " + SHIFT + ALT + left", hl.dsp.workspace.move({ monitor = "l" }),
    { description = "Workspace: Move to the monitor left" })
hl.bind(mainMod .. " + SHIFT + ALT + right", hl.dsp.workspace.move({ monitor = "r" }),
    { description = "Workspace: Move to the monitor right" })
hl.bind(mainMod .. " + SHIFT + ALT + up", hl.dsp.workspace.move({ monitor = "u" }),
    { description = "Workspace: Move to the monitor above" })
hl.bind(mainMod .. " + SHIFT + ALT + down", hl.dsp.workspace.move({ monitor = "d" }),
    { description = "Workspace: Move to the monitor below" })

-- Scroll workspaces (mouse wheel; NOT a mouse drag bind, so no { mouse = true }).
-- NOTE: SUPER+mouse binds are broken by a Hyprland 0.55+ regression (PR #14633
-- aggregates modifier state across all keyboard devices on focus-enter, so SUPER
-- held on the real keyboard is overwritten by empty-mod devices). The 3-finger
-- touchpad swipe below is the primary mouse/touch path instead.
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Workspace: Next" })
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { description = "Workspace: Previous" })

-- 1:1 swipe like GNOME/KDE. Native, no plugin. This is the robust touchpad path:
-- it bypasses both the SUPER+mouse mod-aggregation regression and the bar's
-- touchpad-emulated-scroll guard.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Mouse drag/resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),
    { description = "Window: Drag to move", mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(),
    { description = "Window: Drag to resize", mouse = true })

-- Volume and brightness call the shell, which sets the volume on the Pipewire
-- node directly and drives brightnessctl for the backlight. IMPORTANT: the path
-- must be explicit because Hyprland's exec PATH does NOT include ~/.local/bin,
-- so a bare command is silently not found and the key does nothing. Steps are
-- percent and signed: 5/-5 coarse, 1/-1 on ALT, and 100/-100 slam brightness to
-- a rail. Volume is still capped at 150% for boost.
--
-- There is deliberately NO on-screen display: the bar's audio/backlight modules
-- are the readout, which is why swayosd was removed here and never replaced (it
-- also got this backlight wrong -- raise no-ops, lower raises -- while returning
-- success).
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("quickshell ipc call shell volume 5"),
    { description = "Media: Volume up" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("quickshell ipc call shell volume -5"),
    { description = "Media: Volume down" })
hl.bind("ALT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("quickshell ipc call shell volume 1"),
    { description = "Media: Volume up a little" })
hl.bind("ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd("quickshell ipc call shell volume -1"),
    { description = "Media: Volume down a little" })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("quickshell ipc call shell mute"),
    { description = "Media: Mute output" })
-- Also cycles the default sink, which the plain mute key does not.
hl.bind(mainMod .. " + XF86AudioMute", hl.dsp.exec_cmd(
    [[quickshell ipc call shell mute && sleep 0.3 && pactl set-default-sink $(pactl list short sinks | grep -v "Monitor" | awk '{print $1}' |head -1)]]),
    { description = "Media: Mute output and switch sink" })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("quickshell ipc call shell micMute"),
    { description = "Media: Mute the microphone" })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"),
    { description = "Media: Play or pause" })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),
    { description = "Media: Next track" })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),
    { description = "Media: Previous track" })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("quickshell ipc call shell brightness 5"),
    { description = "Media: Brightness up" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("quickshell ipc call shell brightness -5"),
    { description = "Media: Brightness down" })
hl.bind("SHIFT + XF86MonBrightnessUp", hl.dsp.exec_cmd("quickshell ipc call shell brightness 100"),
    { description = "Media: Brightness to full" })
hl.bind("SHIFT + XF86MonBrightnessDown", hl.dsp.exec_cmd("quickshell ipc call shell brightness -100"),
    { description = "Media: Brightness to minimum" })

hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd("brightnessctl -d *::kbd_backlight set +10%"),
    { description = "Media: Keyboard backlight up" })
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d *::kbd_backlight set 10%-"),
    { description = "Media: Keyboard backlight down" })

-- Laptop lid close/open is handled by hypridle -- see hypridle.conf.
