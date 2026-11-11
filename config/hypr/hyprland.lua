require('monitors')
require('autostart')
require('visual_effects')
require('rules')
require('keybindings')
require('plugins')

hl.config({
    ecosystem = {
        no_donation_nag = true,
        no_update_news = true,
    },
    general = {
        layout = "scrolling",
        extend_border_grab_area = 30,
        gaps_in = 5,
        allow_tearing = true,
    },
    misc = {
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    scrolling = {
        fullscreen_on_one_column = true,
    },
    render = {
        cm_enabled = false,
    },
    xwayland = {
        force_zero_scaling = true
    },

    input = {
        kb_layout  = "us,ru",
        kb_variant = ",",
        kb_model   = "",
        kb_options = "grp:caps_toggle",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = -0.5,

        touchpad = {
            natural_scroll = true,
            scroll_factor = 0.3,
        },
    },
})
