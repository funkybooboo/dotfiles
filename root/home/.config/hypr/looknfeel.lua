-- Look and feel: general/dwindle/master/group/decoration/cursor/binds/misc/
-- ecosystem/xwayland + curves and animations.
-- Translated from looknfeel.conf. Option names with dashes use underscores
-- in Lua (hide-on-key-press -> hide_on_key_press, etc.). `col.*` colors nest
-- under a `col` table. bezier/animation lines become hl.curve/hl.animation
-- calls (NOT entries in the animations table).

-- general
hl.config({
    general = {
        gaps_in      = 3,
        gaps_out     = 5,
        border_size  = 1,
        col = {
            active_border   = "rgba(cba6f7ff)", -- THEME: active_border (catppuccin mauve)
            inactive_border = "rgba(45475aaa)", -- THEME: inactive_border
        },
        layout       = "dwindle",
        allow_tearing = false,
    },
})

-- dwindle
hl.config({
    dwindle = {
        preserve_split = true,
        force_split    = 2,
    },
})

-- master
hl.config({
    master = {
        new_status = "master",
    },
})

-- group / groupbar (catppuccin mocha -- matches the waybar theme)
hl.config({
    group = {
        groupbar = {
            enabled    = true,
            font_size  = 12,
            gradients  = true,
            col = {
                active         = "rgba(cba6f7ff)",
                inactive       = "rgba(45475aaa)",
                locked_active   = "rgba(fab387ff)",
                locked_inactive = "rgba(45475aaa)",
            },
        },
    },
})

-- decoration
hl.config({
    decoration = {
        rounding         = 10,
        active_opacity   = 1.0,
        inactive_opacity = 0.95,
        blur = {
            enabled             = true,
            size                = 6,
            passes              = 3,
            new_optimizations   = true,
        },
        shadow = {
            enabled      = true,
            range        = 8,
            render_power = 2,
            color        = "rgba(11111bee)", -- THEME: shadow
        },
    },
})

-- animations (enabled flag, then curves + animation calls)
hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("easeOutQuint", {
    type   = "bezier",
    points = { { 0.23, 1 }, { 0.32, 1 } },
})
hl.curve("easeInOutCubic", {
    type   = "bezier",
    points = { { 0.65, 0 }, { 0.35, 1 } },
})

hl.animation({ leaf = "windows",    enabled = true, speed = 3,   bezier = "easeOutQuint",   style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.5, bezier = "easeInOutCubic", style = "popin 80%" })
hl.animation({ leaf = "border",     enabled = true, speed = 3,   bezier = "easeOutQuint" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3,   bezier = "easeInOutCubic" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3,   bezier = "easeOutQuint" })

-- cursor
hl.config({
    cursor = {
        hide_on_key_press = true,
        no_warps          = false,
    },
})

-- binds
hl.config({
    binds = {
        hide_special_on_workspace_change = true,
    },
})

-- misc (looknfeel portion; input.conf has its own misc block for DPMS wake)
hl.config({
    misc = {
        force_default_wallpaper      = 0,
        disable_hyprland_logo        = true,
        disable_splash_rendering     = true,
        disable_scale_notification   = true,
        focus_on_activate            = true,
        on_focus_under_fullscreen    = 1,
        anr_missed_pings             = 3,
    },
})

-- ecosystem
hl.config({
    ecosystem = {
        no_update_news = true,
    },
})

-- xwayland
hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})
