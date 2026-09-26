local variables    = require('variables')
local programs     = variables.programs
local mainMod      = variables.mainMod
local launchPrefix = variables.launchPrefix


-- ================================ --
--      APPS & LAUNCHERS            --
-- ================================ --
hl.bind(mainMod .. " + backspace", hl.dsp.exec_cmd(launchPrefix .. programs.terminal))
-- Tap SUPER alone. Release bind: cancelled only if another Hyprland bind fired
-- meanwhile, so SUPER + an unbound key still opens the menu on release.
hl.bind(mainMod .. " + Super_L", hl.dsp.exec_cmd(launchPrefix .. programs.menu), { release = true })
hl.bind(mainMod .. " + e", hl.dsp.exec_cmd(launchPrefix .. programs.fileManager))
-- Windows' own Task Manager shortcut, repurposed the same way here.
-- --class gives this kitty instance its own app_id (kitty-btop, distinct
-- from plain "kitty") so rules.lua can size it without touching every
-- other kitty window.
hl.bind("CTRL + SHIFT + ESCAPE", hl.dsp.exec_cmd(launchPrefix .. programs.terminal .. " --class kitty-btop -e btop"))


-- ================================ --
--      WINDOW MANAGEMENT           --
-- ================================ --
hl.bind(mainMod .. " + c", hl.dsp.window.close())
hl.bind(mainMod .. " + q", hl.dsp.window.close())
hl.bind(mainMod .. " + space", hl.dsp.window.float({ action = "toggle" }))
-- Float + pin (PiP-style, follows across workspaces); again restores tiled.
hl.bind(mainMod .. " + ALT + space", function()
    local w = hl.get_active_window()
    if not w then return end
    local on = not w.pinned
    hl.dispatch(hl.dsp.window.float({ action = on and "on" or "off" }))
    hl.dispatch(hl.dsp.window.pin({ action = on and "on" or "off" }))
end)
hl.bind(mainMod .. " + f", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + m", hl.dsp.window.fullscreen({ mode = 1 })) -- maximize (keeps bar/borders)
hl.bind(mainMod .. " + b", hl.dsp.window.pseudo())
hl.bind("ALT + tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:274", hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

hl.bind(mainMod .. " + mouse_down", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
hl.bind(mainMod .. " + CONTROL + mouse_down", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
hl.bind(mainMod .. " + CONTROL + mouse_up", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))


-- ================================ --
--          WORKSPACES              --
-- ================================ --
-- Numeric wraparound workspace cycling (1-2-3-4-1), even through empty
-- workspaces -- Hyprland's built-in +1/-1 is occupancy-aware, which isn't
-- what we want here. Monitor names/ranges match rules.lua's workspace_rule
-- assignment (MONITOR1 -> 1-4, MONITOR2 -> 5-8); update both when the real
-- second monitor's output name is known on a new host. gestures.lua's
-- touchpad workspace swipe reuses this same script in --auto mode.
local cycleWs = "~/.config/hypr/scripts/cycle-workspace.sh"

hl.bind(mainMod .. " + right", hl.dsp.exec_cmd(cycleWs .. " " .. variables.monitor1 .. " 1 4 +1"))
hl.bind(mainMod .. " + left", hl.dsp.exec_cmd(cycleWs .. " " .. variables.monitor1 .. " 1 4 -1"))
hl.bind(mainMod .. " + ALT + right", hl.dsp.exec_cmd(cycleWs .. " " .. variables.monitor2 .. " 5 8 +1"))
hl.bind(mainMod .. " + ALT + left", hl.dsp.exec_cmd(cycleWs .. " " .. variables.monitor2 .. " 5 8 -1"))

for i = 1, 8 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
end


-- ================================ --
--       SCROLLING LAYOUT           --
-- ================================ --
-- Niri-style column navigation (hyprland.lua sets general.layout =
-- "scrolling", Hyprland's own native layout -- no plugin). h/l/j/k are the
-- vim-directional set; tasking.lua's hyprtasking overview panning moved to
-- comma/period to make room (see tasking.lua).
hl.bind(mainMod .. " + h",         hl.dsp.layout("focus l"))
hl.bind(mainMod .. " + l",         hl.dsp.layout("focus r"))
hl.bind(mainMod .. " + j",         hl.dsp.layout("focus d"))
hl.bind(mainMod .. " + k",         hl.dsp.layout("focus u"))
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.layout("swapcol r"))
-- Stack/unstack within a column, keyboard-only equivalent of dragging a
-- window onto another one.
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.layout("consume")) -- pull into the previous column
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.layout("expel"))   -- pop out into its own column
hl.bind(mainMod .. " + minus",     hl.dsp.layout("colresize -0.1"))
hl.bind(mainMod .. " + equal",     hl.dsp.layout("colresize +0.1"))


-- ================================ --
--          SYSTEM / UI             --
-- ================================ --
hl.bind(mainMod .. " + p", hl.dsp.exec_cmd("qs ipc call powermenu toggle"))
hl.bind(mainMod .. " + v", hl.dsp.exec_cmd("qs ipc call clipboard toggle"))
hl.bind(mainMod .. " + t", hl.dsp.exec_cmd("qs ipc call thememenu toggle"))
hl.bind(mainMod .. " + grave", hl.dsp.exec_cmd("qs ipc call topbar toggle && qs ipc call dock toggle"))
hl.bind(mainMod .. " + n", hl.dsp.exec_cmd("qs ipc call settings open"))
hl.bind(mainMod .. " + SHIFT + n", hl.dsp.exec_cmd("qs ipc call notifications toggle"))
hl.bind(mainMod .. " + i", hl.dsp.exec_cmd("qs ipc call panel toggle"))
-- DMS's own wallpaper picker (dash's wallpaper tab): browses ~/walls,
-- picking a wallpaper also drives matugen theming (currentTheme: dynamic).
hl.bind(mainMod .. " + w", hl.dsp.exec_cmd("qs ipc call dash toggle wallpaper"))
-- DMS's built-in lock screen (Modules/Lock); hyprlock retired, see sub-project 6.
-- Off SUPER+L (now scrolling-layout column focus) onto the classic
-- Linux-DE lock convention instead, out of the SUPER namespace entirely.
hl.bind("CTRL + ALT + l", hl.dsp.exec_cmd("qs ipc call lock lock"))
hl.bind(mainMod .. " + escape", hl.dsp.exec_cmd("hyprctl reload"))
-- satty replaces the old raw grim|tee|wl-copy pipe: annotates before
-- saving, copies to clipboard itself on save/close.
hl.bind("PRINT", hl.dsp.exec_cmd('grim -g "$(slurp)" - | satty --filename - --output-filename ~/screenshot_$(date +%Y%m%d_%H%M%S).png'))
hl.bind(mainMod .. " + s", hl.dsp.exec_cmd('grim -g "$(slurp)" - | satty --filename - --output-filename ~/screenshot_$(date +%Y%m%d_%H%M%S).png'))


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

-- Media control
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })  -- duplicate of Pause
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
