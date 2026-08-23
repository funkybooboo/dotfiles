-- Environment variables.
-- Translated from env.conf. hyprlang `env = K,V` and `env = K=V` both become
-- `hl.env("K", "V")` -- the Lua form always takes key and value as separate
-- args, regardless of the original separator.

hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("KDE_SESSION_VERSION", "5")
hl.env("KDE_FULL_SESSION", "true")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("GTK_THEME", "Adwaita-dark")
hl.env("GTK2_RC_FILES", "/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc")
hl.env("GTK3_RC_FILES", "/usr/share/themes/Adwaita-dark/gtk-3.0/gtk.css")
hl.env("XCOMPOSEFILE", "~/.XCompose")
