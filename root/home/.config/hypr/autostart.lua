-- Autostart.
-- Translated from autostart.conf.
--   exec-once = cmd  -> hl.on("hyprland.start", ...) -- fires once at startup
--   exec = cmd       -> hl.on("config.reloaded", ...) -- re-fires on each reload

hl.on("hyprland.start", function() hl.exec_cmd("bluetoothctl power off") end)

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user import-environment $(env | cut -d= -f1 | tr '\\n' ' ')")
end)
hl.on("hyprland.start", function() hl.exec_cmd("xsettingsd &") end)
hl.on("hyprland.start", function()
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
end)
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
end)
-- Wallpaper + hyprpaper are owned by the systemd user service hypr-wallpaper.service
-- (enabled by migration 000310). It runs monitor-watcher.sh, which calls
-- set-wallpaper.sh at startup and on monitoradded/monitorremoved events, and
-- set-wallpaper.sh starts hyprpaper. Do NOT also spawn them here -- doing so
-- multiplies the watchers and hyprpaper processes, so every monitor flap
-- (e.g. a flaky external DP cable) fires killall+restart several times in
-- parallel, which makes all screens flash black on a loop.
hl.on("hyprland.start", function() hl.exec_cmd("uwsm app -- mako") end)

-- swayosd-server is no longer autostarted: volume/brightness state is shown
-- live in the waybar pulseaudio/backlight modules (icon + percent) instead of
-- a floating OSD, and media-keys applies changes via wpctl/brightnessctl.

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- /usr/lib/hyprpolkitagent/hyprpolkitagent")
end)
hl.on("hyprland.start", function() hl.exec_cmd("uwsm app -- hypridle") end)
hl.on("hyprland.start", function() hl.exec_cmd("uwsm app -- waybar") end)
hl.on("hyprland.start", function() hl.exec_cmd("uwsm app -- wl-paste --watch cliphist store") end)
