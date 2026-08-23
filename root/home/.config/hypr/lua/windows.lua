-- Window rules.
-- Translated from windows.conf plus the two `windowrule` lines that were at
-- the bottom of input.conf. On hyprlang (0.56.2) ALL of these were silent
-- no-ops; in Lua they apply at window creation (zero tile-then-float flash).
-- Rules evaluate top-to-bottom, so order is preserved from the original files.
-- The Lua effect key for idle inhibit is `idle_inhibit` (underscore).
-- `size`/`move` take a table of two values; values may be numbers or string
-- expressions evaluated by Hyprland's size calculator (monitor_w / monitor_h).

-- suppress_event: ignore maximize requests from all apps
hl.window_rule({
    name          = "suppress-maximize",
    match         = { class = ".*" },
    suppress_event = "maximize",
})

-- default opacity tag + value (applies to every window), then per-app opaque
-- overrides below. Order preserved from windows.conf so the per-app 1.0 rules
-- override the default 0.97 0.9.
hl.window_rule({
    name  = "tag-default-opacity",
    match = { class = ".*" },
    tag   = "+default-opacity",
})
hl.window_rule({
    name     = "default-opacity",
    match    = { tag = "default-opacity" },
    opacity  = "0.97 0.9",
})

hl.window_rule({ name = "mpv-opacity",          match = { class = "^(mpv)$" },           opacity = "1.0 1.0" })
hl.window_rule({ name = "vlc-opacity",          match = { class = "^(vlc)$" },           opacity = "1.0 1.0" })
hl.window_rule({ name = "firefox-opacity",      match = { class = "^(firefox)$" },       opacity = "1.0 1.0" })
hl.window_rule({ name = "chromium-opacity",     match = { class = "^(chromium)$" },      opacity = "1.0 1.0" })
hl.window_rule({ name = "google-chrome-opacity",match = { class = "^(google-chrome)$" }, opacity = "1.0 1.0" })
hl.window_rule({ name = "obs-opacity",          match = { class = "^(obs)$" },           opacity = "1.0 1.0" })

-- screen-share indicator -> special workspace, silent
hl.window_rule({
    name      = "screen-share",
    match     = { title = "^(is sharing your screen)$" },
    workspace = "special silent",
})

-- no-focus rule for empty XWayland windows (fixes drag issues)
hl.window_rule({
    name  = "xwayland-nofocus",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- imv: floating, fixed 875x600, centered
hl.window_rule({
    name   = "imv",
    match  = { class = "^(imv)$" },
    float  = true,
    size   = { 875, 600 },
    center = true,
})

-- mpv: always floating + centered, 85%x90% (the flash-fix size)
hl.window_rule({
    name   = "mpv-float",
    match  = { class = "^(mpv)$" },
    float  = true,
    size   = { "monitor_w * 0.85", "monitor_h * 0.90" },
    center = true,
})

-- pavucontrol / blueman-manager: floating + centered
hl.window_rule({ name = "pavucontrol",    match = { class = "^(pavucontrol)$" },     float = true, center = true })
hl.window_rule({ name = "blueman-manager",match = { class = "^(blueman-manager)$" }, float = true, center = true })

-- Apps launched via hypr-float-launch keybinds/waybar icons that don't run
-- inside ghostty (so they don't get the hypr-float-<pid> title marker).
-- Float them at creation by initial_class so there's no tile-then-float flash.
hl.window_rule({
    name   = "float-launch-thunar",
    match  = { initial_class = "^(thunar)$" },
    float  = true,
    size   = { "monitor_w * 0.85", "monitor_h * 0.90" },
    center = true,
})
hl.window_rule({
    name   = "float-launch-signal",
    match  = { initial_class = "^(Signal|signal)$" },
    float  = true,
    size   = { "monitor_w * 0.85", "monitor_h * 0.90" },
    center = true,
})
hl.window_rule({
    name   = "float-launch-nwg-displays",
    match  = { initial_class = "^(nwg-displays)$" },
    float  = true,
    size   = { "monitor_w * 0.85", "monitor_h * 0.90" },
    center = true,
})

-- thunar progress/confirm/warning/question dialogs
hl.window_rule({
    name  = "thunar-dialogs",
    match = { class = "^(thunar)$", title = "^(Progress|Confirm|Warning|Question)" },
    float = true,
})

-- generic file dialogs
hl.window_rule({
    name  = "file-dialogs",
    match = { title = "^(Open|Save|File|Folder)$" },
    float = true,
})

-- Windows launched by hypr-float-launch get --title=hypr-float-<pid> so they
-- float IMMEDIATELY at creation (no tiled-then-float flash). hyprlauncher and
-- other apps that don't use this title stay tiled.
hl.window_rule({
    name   = "float-launch-ghostty",
    match  = { initial_title = "^(hypr-float.*)$" },
    float  = true,
    size   = { "monitor_w * 0.85", "monitor_h * 0.90" },
    center = true,
})

-- idle inhibit: tag mpv/zoom, then inhibit on that tag
hl.window_rule({ name = "mpv-noidle", match = { class = "^(mpv)$" },  tag = "+noidle" })
hl.window_rule({ name = "zoom-noidle",match = { class = "^(zoom)$" }, tag = "+noidle" })
hl.window_rule({
    name         = "noidle-inhibit",
    match        = { tag = "noidle" },
    idle_inhibit = "always",
})

-- Scroll nicely in the terminal (was at the bottom of input.conf).
hl.window_rule({
    name            = "alacritty-kitty-scroll",
    match           = { class = "(Alacritty|kitty)" },
    scroll_touchpad = 1.5,
})
hl.window_rule({
    name            = "ghostty-scroll",
    match           = { class = "com.mitchellh.ghostty" },
    scroll_touchpad = 0.2,
})
