-- gestures.lua — touchpad gesture bindings.
--
-- Only 3-finger left/right is bound. Everything else that was tried here
-- (3-finger up/down for fullscreen/float, 2-finger pinch for resize) never
-- fired -- confirmed live via libinput debug-events that the touchpad and
-- libinput were reporting those gestures cleanly, so the gap was in
-- hl.gesture()'s own handling of non-workspace string actions, not
-- hardware. Not worth chasing further; dropped instead. Plain two-finger
-- scrolling and pinch are left fully unclaimed, so libinput's own
-- scroll/pinch-to-zoom (where an app supports it) still works normally.

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
