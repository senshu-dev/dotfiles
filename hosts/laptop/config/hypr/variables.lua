-- User-tunable settings shared across the hypr/*.lua config: programs to
-- launch, the keybind modifier, and monitor output names. Host-specific --
-- see hosts/<host>/hypr/variables.lua; this copy is for "laptop".

local variables = {
    mainMod      = "SUPER",
    launchPrefix = "uwsm app -- ",

    programs = {
        terminal        = "kitty",
        fileManager     = "nautilus",
        menu            = "qs ipc call launcher toggle",
    },

    -- Output names driving workspace assignment (rules.lua) and per-monitor
    -- workspace cycling (keybindings.lua). Single built-in panel (eDP-1);
    -- monitor2 only matters if an external display gets plugged in.
    monitor1 = "eDP-1",
    monitor2 = "HDMI-A-1",
}

return variables
