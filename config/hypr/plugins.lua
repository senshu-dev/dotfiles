-- ================================ --
--     PLUGIN ANIMATIONS            --
-- ================================ --

-- hyprfocus
hl.animation({ leaf = "hyprfocusIn",  enabled = true, speed = 2, bezier = "quick" })
hl.animation({ leaf = "hyprfocusOut", enabled = true, speed = 4, bezier = "almostLinear" })


-- ================================ --
--     PLUGIN CONFIG                --
-- ================================ --

hl.config({
    plugin = {
        hyprfocus = {
            enable = true,
            animate_floating = true,
            keyboard_focus_animation = "shrink",
            mouse_focus_animation = "none",
            group_focus_animation = "shrink",
            shrink_percentage = 0.96,
        },

        dynamic_cursors = {
            enabled = true,
            mode = "tilt",
            threshold = 2,

            tilt = {
                limit = 4000,
                activation = "negative_quadratic",
                window = 80,
                full = 45,
            },

            shake = {
                enabled = true,
                threshold = 5.0,
                base = 3.5,
                speed = 5.0,
                timeout = 1500,
                effects = true,
            },
        },

        scrolloverview = {
            scale = 0.35,
            workspace_gap = 60,
            layout = "auto",
            wallpaper = 2,
            blur = true,
            shadow = {
                enabled = true,
                range = 40,
            },
            cross_monitor_drag = true,
        },
    },
})


-- ================================ --
--     PLUGIN KEYBINDS              --
-- ================================ --

-- scrolloverview
hl.bind("SUPER + tab", function() hl.plugin.scrolloverview.overview("toggle all") end)

-- hyprglass
if hl.plugin.hyprglass then
    local hg = hl.plugin.hyprglass

    hg.config({
        default_theme = "dark",
        default_preset = "default",
        skip_opaque_windows = true,
        blur_fold = true,

        blur_strength = 0.3,
        blur_iterations = 1,
        noise_strength = 0.0,
        refraction_strength = 1.0,
        chromatic_aberration = 0.9,
        fresnel_strength = 0.8,
        specular_strength = 0.9,
        specular_angle = 315,
        lens_distortion = 0.5,
        glass_opacity = 0.6,
        tint_color = 0x1a1b2608,

        dark = {
            brightness = 0.95,
            contrast = 0.92,
            saturation = 0.8,
            adaptive_dim = 0.3,
        },

        layers = {
            enabled = false,
        },

        windows = {
            background_cache = true,
            live_resample = true,
            live_resample_fps = 30,
        },
    })

end
