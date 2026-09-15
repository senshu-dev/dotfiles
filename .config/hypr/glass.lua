-- HyprGlass: liquid-glass blur/refraction effect for transparent windows
-- (https://github.com/hyprnux/hyprglass). Installed via `hyprpm` (see
-- setup.sh's `setup_hyprglass`). Layers on top of visual.lua's native
-- decoration.blur rather than replacing it -- manage_window_blur defaults
-- to true, so the plugin drives the existing compositor blur itself.
--
-- Guarded: autostart.lua's `hyprpm reload -n` only loads the plugin on the
-- "hyprland.start" event, which fires after this file's first parse on a
-- fresh launch -- an unguarded hl.plugin.hyprglass.config() call would hit
-- a nil plugin table and error out.
if hl.plugin.hyprglass then
    hl.plugin.hyprglass.config({
        default_theme  = "dark",
        -- "clear" (the built-in default I first picked) hardcodes
        -- blurStrength=0 -- looks like plain transparency, no visible
        -- blur/refraction. "glass" is the plugin's most visible preset
        -- (blurStrength 1.0, refractionStrength 8.0, chromaticAberration
        -- 0.5) -- src/BuiltInPresets.hpp in hyprnux/hyprglass.
        default_preset = "glass",
    })
end
