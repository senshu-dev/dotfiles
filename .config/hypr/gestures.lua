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
--
-- `action` here needs an hl.dsp.* dispatcher descriptor, the same object
-- hl.bind() takes in keybindings.lua -- a bare string like "fullscreen"
-- matches the *native hyprlang* `gesture = fingers, direction, action`
-- syntax, not this Lua binding, and gets silently dropped (no error, gesture
-- just never fires). Confirmed live: libinput's own debug-events showed
-- clean 3-finger up/down swipes reaching the compositor -- the gesture was
-- always recognized, only the string-action wiring was wrong.
hl.gesture({ fingers = 3, direction = "up",   action = hl.dsp.window.fullscreen() })
hl.gesture({ fingers = 3, direction = "down", action = hl.dsp.window.float({ action = "toggle" }) })

-- 2-finger horizontal swipe was bound here for tape-panning but never
-- fires: confirmed against libinput's own docs (wayland.freedesktop.org/
-- libinput, Gestures) -- swipe gestures require 3+ fingers by design, 2
-- fingers only ever report as scroll or pinch. Removed rather than left
-- as dead config. If tape-panning by touchpad is still wanted, it needs a
-- different finger count (3 left/right is already workspace-cycle above)
-- or a plain 2-finger horizontal *scroll* binding instead of a gesture.

-- 2-finger pinch (any direction, spread or diagonal -- pinch is just the
-- change in distance between the two contact points, angle doesn't
-- matter): resize the focused window, spreading grows it, pinching
-- shrinks it. Free resize on floating windows, adjusts split/column size
-- on tiled/scrolling ones. Same hl.dsp.* fix as fullscreen/float above --
-- the bare "resize" string never fired even though libinput's
-- debug-events confirmed clean pinch detection (scale 1.09->2.28 spread,
-- 0.86->0.32 pinch-in).
hl.gesture({ fingers = 2, direction = "pinch", action = hl.dsp.window.resize() })
