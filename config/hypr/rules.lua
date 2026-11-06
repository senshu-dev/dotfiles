hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
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

hl.layer_rule({
    name = "quickshell-glass",
    match = { namespace = "quickshell-bar" },
    blur = true,
    ignore_alpha = 0.1,
})

hl.window_rule({
    name    = "kitty-opacity",
    match   = { class = "kitty" },
    opacity = "1.0 override 1.0 override",
})

hl.window_rule({
    name    = "zen-opacity",
    match   = { class = "zen" },
    opacity = "1.0 override 1.0 override",
})

hl.window_rule({
    name            = "btop-width",
    match           = { class = "^kitty-btop$" },
    scrolling_width = 0.6,
})

hl.window_rule({
    match      = { class = "(?i)(^steam_app_.*|.*game.*)" },
    no_anim    = true,
    no_blur    = true,
    no_shadow  = true,
    rounding   = 0,
    opacity    = "1.0 override 1.0 override",
    immediate  = true,
    content    = "game",
    fullscreen = true
})
hl.window_rule({
    match     = { content = "game" },
    no_anim   = true,
    no_blur   = true,
    no_shadow = true,
    rounding  = 0,
    opacity   = "1.0 override 1.0 override",
    immediate = true,
})
