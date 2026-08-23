-- Input device configuration + DPMS wake misc.
-- Translated from input.conf (the two `windowrule` lines that were at the
-- bottom of input.conf moved to windows.lua -- window rules are global).
-- hyprlang options written with dashes become Lua underscore keys
-- (tap-to-click -> tap_to_click).

hl.config({
    input = {
        kb_layout    = "us",
        kb_options   = "compose:caps",
        follow_mouse = 1,
        sensitivity  = 0.2,
        touchpad = {
            natural_scroll         = false,
            tap_to_click           = true,
            drag_lock              = true,
            clickfinger_behavior   = true,
            middle_button_emulation = true,
            disable_while_typing   = true,
            scroll_factor          = 1.0,
        },
    },
})

hl.config({
    misc = {
        key_press_enables_dpms  = true,
        mouse_move_enables_dpms = true,
    },
})

hl.device({
    name           = "pixa3854:00-093a:0274-mouse",
    sensitivity    = 0.2,
    natural_scroll = false,
})

hl.device({
    name           = "imexps/2-generic-explorer-mouse",
    sensitivity    = 0.2,
    natural_scroll = false,
})
