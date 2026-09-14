-- User-tunable settings shared across the hypr/*.lua config: programs to
-- launch, the keybind modifier, and monitor output names. Host-specific --
-- see hosts/<host>/hypr/variables.lua; this copy is for "desktop".

local variables = {
    mainMod      = "SUPER",
    launchPrefix = "uwsm app -- ",

    programs = {
        terminal        = "kitty",
        fileManager     = "nautilus",
        menu            = "qs ipc call launcher toggle",
    },

    -- Output names driving workspace assignment (rules.lua) and per-monitor
    -- workspace cycling (keybindings.lua).
    monitor1 = "DP-1",
    monitor2 = "HDMI-A-1",
}

return variables
