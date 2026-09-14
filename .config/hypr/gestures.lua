-- gestures.lua — touchpad gesture bindings.
--
-- fingers x direction disambiguates each swipe; pinch is its own gesture
-- type (finger-distance change), so it never collides with the swipes
-- below. Plain two-finger vertical scrolling isn't bound here at all --
-- with no hl.gesture claiming it, libinput's own two-finger scroll
-- handles it, which is exactly the "just let me scroll" behaviour.

local variables = require('variables')
local cycleWs = "~/.config/hypr/scripts/cycle-workspace.sh"

-- 3-finger left/right: same wraparound per-monitor cycling as
-- SUPER+Left/Right (keybindings.lua), but a touchpad gesture has no
-- "which monitor" the way a keybind does -- --auto (cycle-workspace.sh)
-- resolves it from whichever monitor currently has focus.
local function cycleWorkspaceAuto(dir)
    return function()
        hl.exec_cmd(cycleWs .. " --auto " .. dir
            .. " " .. variables.monitor1 .. ":1:4"
            .. " " .. variables.monitor2 .. ":5:8")
    end
end

hl.gesture({ fingers = 3, direction = "left",  action = cycleWorkspaceAuto("-1") })
hl.gesture({ fingers = 3, direction = "right", action = cycleWorkspaceAuto("+1") })

-- 3-finger up/down: fullscreen / float (moved off 2-finger so plain
-- two-finger vertical stays a normal scroll).
hl.gesture({ fingers = 3, direction = "up",   action = "fullscreen" })
hl.gesture({ fingers = 3, direction = "down", action = "float" })

-- 2-finger left/right: pan the scrolling-layout tape (native action,
-- niri-style column scroll).
hl.gesture({ fingers = 2, direction = "horizontal", action = "scroll_move" })

-- 2-finger pinch (any direction, spread or diagonal -- pinch is just the
-- change in distance between the two contact points, angle doesn't
-- matter): resize the focused window, spreading grows it, pinching
-- shrinks it. Native `resize` action -- free resize on floating windows,
-- adjusts split/column size on tiled/scrolling ones.
hl.gesture({ fingers = 2, direction = "pinch", action = "resize" })
