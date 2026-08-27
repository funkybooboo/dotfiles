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
-- LibreOffice picks its VCL backend from XDG_CURRENT_DESKTOP, and "Hyprland"
-- is not a name it recognises, so it can fall back to the generic X11 `gen`
-- plugin, which draws its own light chrome and ignores every theme layer
-- above. gtk3 is always present (a hard dependency of xdg-desktop-portal-gtk),
-- so pinning the backend is safe.
hl.env("SAL_USE_VCLPLUGIN", "gtk3")
hl.env("XCOMPOSEFILE", "~/.XCompose")

-- Ensure Hyprland's exec PATH includes ~/.local/bin. The systemd user session
-- PATH (inherited from PAM/nix at login) does NOT include it, so a bare-name
-- script in a bind silently fails to resolve and the key does nothing -- this
-- is exactly what broke the media keys. environment.d CANNOT fix this: it is
-- unable to override an already-set PATH (verified empirically -- a spawned
-- user service still lacked ~/.local/bin). hl.env setenv's into Hyprland's own
-- process, so every exec_cmd child inherits the extended PATH. Guarded so a
-- config reload (which re-runs this and would see the already-extended PATH)
-- does not keep appending duplicates.
do
  local cur  = os.getenv("PATH") or ""
  local home = os.getenv("HOME") or ""
  local entry = home .. "/.local/bin"
  if not (":" .. cur .. ":"):find(":" .. entry .. ":", 1, true) then
    hl.env("PATH", cur .. ":" .. entry)
  end
end
