local main_mod = "SUPER"
local launch_prefix = "uwsm app -- "
local programs = {
    terminal     = "kitty",
    file_manager = "nautilus",
    browser      = "zen-browser",
    menu         = "caelestia shell drawers toggle launcher",
    session      = "caelestia shell drawers toggle session",
    dashboard    = "caelestia shell drawers toggle dashboard",
    sidebar      = "caelestia shell drawers toggle sidebar",
    osd          = "caelestia shell drawers toggle osd",
    utilities    = "caelestia shell drawers toggle utilities",
}


-- ================================ --
--      APPS & LAUNCHERS            --
-- ================================ --
hl.bind(main_mod .. " + backspace", hl.dsp.exec_cmd(launch_prefix .. programs.terminal))
hl.bind(main_mod .. " + e", hl.dsp.exec_cmd(launch_prefix .. programs.file_manager))
hl.bind(main_mod .. " + w", hl.dsp.exec_cmd(launch_prefix .. programs.browser))
hl.bind("CTRL + SHIFT + ESCAPE", hl.dsp.exec_cmd(launch_prefix .. programs.terminal .. " --class kitty-btop -e btop"))
hl.bind(main_mod .. " + Super_L", hl.dsp.exec_cmd(programs.menu), { release = true })
hl.bind(main_mod .. " + d", hl.dsp.exec_cmd(programs.dashboard))
hl.bind(main_mod .. " + n", hl.dsp.exec_cmd(programs.sidebar))
hl.bind(main_mod .. " + u", hl.dsp.exec_cmd(programs.utilities))


-- ================================ --
--      WINDOW MANAGEMENT           --
-- ================================ --
hl.bind(main_mod .. " + c", hl.dsp.window.close())
hl.bind(main_mod .. " + q", hl.dsp.window.close())
hl.bind(main_mod .. " + space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(main_mod .. " + ALT + space", function()
    local w = hl.get_active_window()
    if not w then return end
    local on = not w.pinned
    hl.dispatch(hl.dsp.window.float({ action = on and "on" or "off" }))
    hl.dispatch(hl.dsp.window.pin({ action = on and "on" or "off" }))
end)
hl.bind(main_mod .. " + f", hl.dsp.window.fullscreen())
hl.bind(main_mod .. " + m", hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind("ALT + tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end)
hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(main_mod .. " + mouse:274", hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize())

hl.bind(main_mod .. " + mouse_down", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hl.bind(main_mod .. " + mouse_up", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
hl.bind(main_mod .. " + CONTROL + mouse_down", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
hl.bind(main_mod .. " + CONTROL + mouse_up", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))


-- ================================ --
--       SCROLLING LAYOUT           --
-- ================================ --
hl.bind(main_mod .. " + h",         hl.dsp.layout("focus l"))
hl.bind(main_mod .. " + l",         hl.dsp.layout("focus r"))
hl.bind(main_mod .. " + j",         hl.dsp.layout("focus d"))
hl.bind(main_mod .. " + k",         hl.dsp.layout("focus u"))
hl.bind(main_mod .. " + SHIFT + h", hl.dsp.layout("swapcol l"))
hl.bind(main_mod .. " + SHIFT + l", hl.dsp.layout("swapcol r"))
hl.bind(main_mod .. " + SHIFT + j", hl.dsp.layout("consume"))
hl.bind(main_mod .. " + SHIFT + k", hl.dsp.layout("expel"))
hl.bind(main_mod .. " + minus",     hl.dsp.layout("colresize -0.1"))
hl.bind(main_mod .. " + equal",     hl.dsp.layout("colresize +0.1"))


-- ================================ --
--          WORKSPACES              --
-- ================================ --
-- 4 workspaces per monitor: DP gets 1-4, HDMI gets 5-8, etc.
-- SUPER+1..4: switch to workspace on focused monitor (monitor-relative).
-- SUPER+SHIFT+1..4: move window to that workspace.
-- SUPER+Left/Right: cycle workspaces. SUPER+Up/Down: cycle monitors.
-- SUPER+SHIFT+Up/Down: move window to next/prev monitor.

local cycle_ws = "~/.config/hypr/scripts/cycle-workspace.sh"

hl.bind(main_mod .. " + right", hl.dsp.exec_cmd(cycle_ws .. " +1"))
hl.bind(main_mod .. " + left",  hl.dsp.exec_cmd(cycle_ws .. " -1"))
hl.bind(main_mod .. " + up",    hl.dsp.focus({ monitor = "+1" }))
hl.bind(main_mod .. " + down",  hl.dsp.focus({ monitor = "-1" }))

-- SUPER+SHIFT+Up/Down: move active window to next/prev monitor
hl.bind(main_mod .. " + SHIFT + up",   hl.dsp.window.move({ monitor = "+1" }))
hl.bind(main_mod .. " + SHIFT + down", hl.dsp.window.move({ monitor = "-1" }))

-- Bind workspaces to monitors: primary monitor gets 1-4, others get 5-8, 9-12, etc.
-- Order: DP outputs first (typically the main display), then HDMI.
-- monitor name → workspace base (0 for ws 1-4, 4 for ws 5-8, etc.)
local monitor_ws_base = {}

local function setup_workspaces()
    local monitors = hl.get_monitors()
    if not monitors then return end

    table.sort(monitors, function(a, b)
        local a_dp = a.name:find("^DP") and 0 or 1
        local b_dp = b.name:find("^DP") and 0 or 1
        if a_dp ~= b_dp then return a_dp < b_dp end
        return a.name < b.name
    end)

    for idx, mon in ipairs(monitors) do
        local base = (idx - 1) * 4
        monitor_ws_base[mon.name] = base
        for ws = base + 1, base + 4 do
            hl.workspace_rule({
                workspace = tostring(ws),
                monitor = mon.name,
                default = (ws == base + 1),
            })
        end
    end

    for idx, mon in ipairs(monitors) do
        local default_ws = tostring((idx - 1) * 4 + 1)
        hl.dispatch(hl.dsp.workspace.move({ workspace = default_ws, monitor = mon.name }))
    end
end
setup_workspaces()

-- SUPER+1..4: switch to workspace N on the focused monitor
-- SUPER+SHIFT+1..4: move active window to that workspace
for i = 1, 4 do
    hl.bind(main_mod .. " + " .. i, function()
        local base = monitor_ws_base[hl.get_active_monitor().name] or 0
        hl.dispatch(hl.dsp.focus({ workspace = tostring(base + i) }))
    end)

    hl.bind(main_mod .. " + SHIFT + " .. i, function()
        local base = monitor_ws_base[hl.get_active_monitor().name] or 0
        hl.dispatch(hl.dsp.window.move({ workspace = tostring(base + i) }))
    end)
end


-- ================================ --
--          SYSTEM / UI             --
-- ================================ --
hl.bind(main_mod .. " + p", hl.dsp.exec_cmd(programs.session))
-- clipboard moved to plugins.lua
hl.bind(main_mod .. " + b", hl.dsp.exec_cmd("caelestia shell drawers toggle bar"))
hl.bind(main_mod .. " + SHIFT + a", hl.dsp.exec_cmd("caelestia shell audio cycleOutput"))
hl.bind(main_mod .. " + escape", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind("CTRL + ALT + l", hl.dsp.exec_cmd("caelestia shell lock lock"))

-- Screenshots via Caelestia
hl.bind("PRINT", hl.dsp.exec_cmd("caelestia screenshot -r -f"))
hl.bind(main_mod .. " + s", hl.dsp.exec_cmd("caelestia screenshot -r -f"))
hl.bind(main_mod .. " + SHIFT + s", hl.dsp.exec_cmd("caelestia screenshot"))


-- ================================ --
--           HARDWARE               --
-- ================================ --

-- Audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Media (via Caelestia mpris)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("caelestia shell mpris next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("caelestia shell mpris playPause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("caelestia shell mpris playPause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("caelestia shell mpris previous"), { locked = true })
