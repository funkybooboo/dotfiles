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

-- group / groupbar
-- Dark tabs throughout, using Catppuccin's elevation ramp rather than a color
-- cue: surface0 is its elevated surface and crust its deepest, so the active tab
-- reads as raised and the rest as recessed. Readability comes from near-white
-- titles on those fills -- text on surface0 is 8.69:1 and subtext0 on crust
-- 8.43:1, against WCAG AA's 4.5:1 (the old white on mauve was 2.03:1). Locked
-- groups keep peach as their signal, 5.15:1 on surface1. Mauve is deliberately
-- absent; it already means "focused window" on the border, in waybar, and in
-- hyprtoolkit.
-- The col.border_* values repeat general{}'s on purpose: grouping is not a focus
-- change, so it should not recolor the border. Left unset they fall back to
-- Hyprland's translucent yellow (0x66ffff00) and olive (0x66777700).
hl.config({
    group = {
        col = {
            border_active          = "rgba(cba6f7ff)",
            border_inactive        = "rgba(45475aaa)",
            border_locked_active   = "rgba(fab387ff)",
            border_locked_inactive = "rgba(45475aaa)",
        },
        groupbar = {
            enabled          = true,
            -- Falls back to misc:font_family (unset, so "Sans") otherwise.
            font_family      = "JetBrainsMono Nerd Font",
            font_size        = 11,
            height           = 18,
            -- The tab fill is drawn ONLY inside the renderer's gradients branch:
            -- the one unconditional rect is the indicator, while the texture
            -- spanning `height` is gated on this. Off, each title renders as bare
            -- text over the wallpaper. col.* hold a single stop each, so the fill
            -- is flat; this is not a visible gradient.
            gradients        = true,
            -- Same split: the tab's shape comes from gradient_rounding, while
            -- rounding/round_only_edges only reach the indicator rect.
            gradient_rounding         = 4,
            gradient_round_only_edges = false,
            -- The indicator is filled with the tab's own color, so it only adds
            -- height below each tab.
            indicator_height = 0,
            gaps_in          = 2,
            gaps_out         = 3,
            col = {
                active          = "rgba(313244ff)",
                inactive        = "rgba(11111bff)",
                locked_active   = "rgba(45475aff)",
                locked_inactive = "rgba(11111bff)",
            },
            text_color                 = "rgba(cdd6f4ff)",
            text_color_inactive        = "rgba(a6adc8ff)",
            text_color_locked_active   = "rgba(fab387ff)",
            text_color_locked_inactive = "rgba(a6adc8ff)",
            font_weight_active         = "bold",
            font_weight_inactive       = "normal",
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

hl.animation({ leaf = "windows",    enabled = true, speed = 2,   bezier = "easeOutQuint",   style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1,   bezier = "easeInOutCubic", style = "popin 80%" })
hl.animation({ leaf = "border",     enabled = true, speed = 2,   bezier = "easeOutQuint" })
hl.animation({ leaf = "fade",       enabled = true, speed = 2,   bezier = "easeInOutCubic" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2,   bezier = "easeOutQuint" })

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
