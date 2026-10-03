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
-- The import-environment/dbus-update handlers above only add or overwrite
-- keys -- they can never remove keys an earlier session left behind, and the
-- user manager plus dbus activation envs live for the whole boot. uwsm
-- launches apps as user units, so they inherit the manager env, not
-- Hyprland's. Before env.lua dropped the fake-KDE pair (KDE_FULL_SESSION /
-- KDE_SESSION_VERSION), every login had imported them, and even after the
-- fix landed the stale keys kept making xdg-open's detectDE (no Hyprland
-- case) take the KDE branch and run missing kde-open5 -- a silent no-op for
-- every "open" from yazi, VS Code links, etc. Scrub the pair on every
-- session start so the manager env can never drift from env.lua's intent.
hl.on("hyprland.start", function()
    -- dbus activation env can only be updated, not unset: empty the keys
    -- there, then remove them from the user manager env entirely.
    hl.exec_cmd("dbus-update-activation-environment --systemd KDE_FULL_SESSION= KDE_SESSION_VERSION=")
    hl.exec_cmd("systemctl --user unset-environment KDE_FULL_SESSION KDE_SESSION_VERSION")
end)
-- Ensure the systemd user graphical session target is up. uwsm normally activates
-- graphical-session.target, but not reliably on every boot, and on the boots it
-- misses every WantedBy=graphical-session unit stays dead -- hyprpolkitagent and
-- the xdg portals among them. hypr-wallpaper.service used to pull the target in
-- as a side effect of its BindsTo=; the keeper unit is that same mechanism
-- without the wallpaper. The target itself is started THROUGH the keeper
-- because systemd refuses a direct `systemctl --user start
-- graphical-session.target` (RefuseManualStart=yes -- verified live: "Operation
-- refused, unit graphical-session.target may be requested by dependency only").
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start graphical-session-keeper.service")
end)
-- quickshell is the whole shell: bar, notifications and tray in one process.
-- It replaced waybar and mako, which used to be started separately from here.
hl.on("hyprland.start", function() hl.exec_cmd("uwsm app -- quickshell") end)

-- swayosd is removed entirely (see 000400-power-management): volume/brightness
-- state is shown live in the quickshell bar's audio/backlight modules
-- instead of a floating OSD, and media-keys applies changes via wpctl/brightnessctl.

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- /usr/lib/hyprpolkitagent/hyprpolkitagent")
end)
hl.on("hyprland.start", function() hl.exec_cmd("uwsm app -- hypridle") end)
hl.on("hyprland.start", function() hl.exec_cmd("uwsm app -- wl-paste --watch cliphist store") end)
-- espanso: `daemon` (not `start`) runs in the foreground so the uwsm scope tracks
-- it and it exits with the session. See migrations/000325-espanso.sh for why
-- espanso's own `service register` is not used.
hl.on("hyprland.start", function() hl.exec_cmd("uwsm app -- espanso daemon") end)
