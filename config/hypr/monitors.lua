-- Adaptive monitor setup: configures any connected monitor at preferred mode.
-- Specific monitors get explicit settings; unknown monitors get sensible defaults.
-- Positions are auto-assigned (Hyprland places them left-to-right).

local known_monitors = {
    ["DP-6"] = {
        mode = "1920x1080@144",
        scale = "1",
        supports_hdr = -1,
    },
    ["HDMI-A-2"] = {
        mode = "1920x1080@75",
        scale = "1",
    },
}

local function setup_monitors()
    local monitors = hl.get_monitors()

    if monitors and #monitors > 0 then
        for _, mon in ipairs(monitors) do
            local known = known_monitors[mon.name]
            if known then
                hl.monitor({
                    output   = mon.name,
                    mode     = known.mode,
                    position = "auto",
                    scale    = known.scale,
                    supports_hdr = known.supports_hdr,
                })
            else
                hl.monitor({
                    output   = mon.name,
                    mode     = "preferred",
                    position = "auto",
                    scale    = "1",
                })
            end
        end
    end

    -- Fallback: catch any monitor not matched above
    hl.monitor({
        output   = "",
        mode     = "preferred",
        position = "auto",
        scale    = "1",
    })
end

setup_monitors()
