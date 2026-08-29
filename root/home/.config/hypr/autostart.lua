-- Autostart.
-- Translated from autostart.conf.
--   exec-once = cmd  -> hl.on("hyprland.start", ...) -- fires once at startup
--   exec = cmd       -> hl.on("config.reloaded", ...) -- re-fires on each reload

hl.on("hyprland.start", function() hl.exec_cmd("bluetoothctl power off") end)

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user import-environment $(env | cut -d= -f1 | tr '\\n' ' ')")
end)
hl.on("hyprland.start", function() hl.exec_cmd("xsettingsd &") end)
-- libadwaita (GTK4) reads none of the gtk-3.0/gtk-4.0 settings.ini keys: it
-- takes the color scheme from the portal's org.freedesktop.appearance, which
-- xdg-desktop-portal-gtk backs with these GSettings keys. gtk-theme and
-- icon-theme have to be set alongside color-scheme or they keep the
-- gsettings-desktop-schemas default of 'Adwaita', contradicting
-- gtk-3.0/settings.ini and xsettingsd.conf.
hl.on("hyprland.start", function()
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'")
end)
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
end)
-- Ensure the systemd user graphical session target + wallpaper service are up.
-- uwsm normally activates graphical-session.target, but it is not 100% reliable
-- (some boots it never reaches the target, so every WantedBy=graphical-session
-- service -- hypr-wallpaper, xdg portals -- stays dead and the wallpaper never
-- appears). Starting hypr-wallpaper.service here also pulls in the target via
-- its BindsTo=, so the whole session stack comes up on every Hyprland start.
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start hypr-wallpaper.service")
end)
-- Wallpaper + hyprpaper are owned by the systemd user service hypr-wallpaper.service
-- (enabled by migration 000310). It runs monitor-watcher.sh, which calls
-- set-wallpaper.sh at startup and on monitoradded/monitorremoved events, and
-- set-wallpaper.sh starts hyprpaper. Do NOT also spawn them here -- doing so
-- multiplies the watchers and hyprpaper processes, so every monitor flap
-- (e.g. a flaky external DP cable) fires killall+restart several times in
-- parallel, which makes all screens flash black on a loop.
hl.on("hyprland.start", function() hl.exec_cmd("uwsm app -- mako") end)

-- swayosd is removed entirely (see 000400-power-management): volume/brightness
-- state is shown live in the waybar pulseaudio/backlight modules (icon + percent)
-- instead of a floating OSD, and media-keys applies changes via wpctl/brightnessctl.

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- /usr/lib/hyprpolkitagent/hyprpolkitagent")
end)
hl.on("hyprland.start", function() hl.exec_cmd("uwsm app -- hypridle") end)
hl.on("hyprland.start", function() hl.exec_cmd("uwsm app -- waybar") end)
hl.on("hyprland.start", function() hl.exec_cmd("uwsm app -- wl-paste --watch cliphist store") end)
