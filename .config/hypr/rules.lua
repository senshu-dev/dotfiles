hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
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

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

hl.layer_rule({
    name = "quickshell-glass",
    match = { namespace = "quickshell-bar" },
    blur = true,
    ignore_alpha = 0.1,
})

hl.window_rule({
    -- let kitty own its translucency via background_opacity (crisp text over
    -- the compositor blur) instead of the global active/inactive_opacity dim.
    name    = "kitty-opacity",
    match   = { class = "kitty" },
    opacity = "1.0 override 1.0 override",
})

hl.window_rule({
    -- zen browser: keep it fully opaque, ignore the global active/inactive_opacity dim
    name    = "zen-opacity",
    match   = { class = "zen" },
    opacity = "1.0 override 1.0 override",
})

hl.window_rule({
    -- btop's panels need real width to render -- min_size is float-only, so
    -- under the scrolling layout this is the native equivalent (starting
    -- column width, not a hard floor: colresize can still shrink it later).
    name            = "btop-width",
    match           = { class = "^kitty-btop$" },
    scrolling_width = 0.6,
})

-- Startup widget group (toggle-widgets.sh, SUPER+G). `move` is
-- monitor-local (origin added automatically); `monitor_x+N`/`monitor_y+N`
-- don't work, use plain numbers or `monitor_w-N`/`monitor_h-N` instead.
-- Not proportional -- redo by hand for a different monitor size.
-- `pin` keeps windows fixed across workspace/column switches.
hl.window_rule({
    name  = "widget-fastfetch-float",
    match = { class = "^widget-fastfetch$" },
    float = true,
    pin   = true,
    size  = "914 620",
    move  = "952 52",
})

hl.window_rule({
    name  = "widget-cava-float",
    match = { class = "^widget-cava$" },
    float = true,
    pin   = true,
    size  = "748 301",
    move  = "monitor_w-865 monitor_h-398",
})

hl.window_rule({
    name  = "widget-clock-float",
    match = { class = "^widget-clock$" },
    float = true,
    pin   = true,
    size  = "419 243",
    move  = "225 107",
})

hl.window_rule({
    name  = "widget-rain-float",
    match = { class = "^widget-rain$" },
    float = true,
    pin   = true,
    size  = "895 594",
    move  = "37 442",
})

local variables = require('variables')
local MONITOR1 = variables.monitor1
local MONITOR2 = variables.monitor2

for _, ws in ipairs({ 1, 2, 3, 4 }) do
  hl.workspace_rule({ workspace = tostring(ws), monitor = MONITOR1 })
end

for _, ws in ipairs({ 5, 6, 7, 8 }) do
  hl.workspace_rule({ workspace = tostring(ws), monitor = MONITOR2 })
end

hl.window_rule({
    match      = { class = "(?i)(^steam_app_|.*game.*)" },
    workspace  = "1",
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