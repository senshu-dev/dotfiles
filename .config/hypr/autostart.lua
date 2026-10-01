hl.on("hyprland.start", function ()
    -- hyprpm doesn't auto-load enabled plugins into a fresh Hyprland
    -- instance on its own -- without this, tasking.lua's binds call into
    -- a nil hl.plugin.hyprtasking and error out the moment they fire.
    hl.exec_cmd("hyprpm reload -n")
    -- dms.service exists (~/.config/systemd/user/dms.service) but stays
    -- disabled: this host's systemd user session never activates
    -- graphical-session.target (Requisite=graphical-session.target fails
    -- every start), a pre-existing gap unrelated to this shell, not fixed
    -- here. Launching directly instead, same as the old bare "quickshell"
    -- line this replaces. No systemd supervision means no auto-restart on
    -- crash either -- loop it ourselves and keep a log so a future crash
    -- leaves evidence instead of just a dead bar.
    hl.exec_cmd("sh -c 'while true; do dms run --config ~/.config/quickshell >>~/.cache/dms-run.log 2>&1; sleep 1; done'")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &")
    -- XWayland has no primary output on its own, so Wine/Proton games took
    -- the first one (HDMI-A-1, at 0,0) as monitor 0: only its 75 Hz modes
    -- were offered and DXVK capped fullscreen games at 75 FPS even though
    -- rules.lua shows them on the 144 Hz main monitor.
    -- ponytail: one-shot, XWayland forgets it if the output gets re-created
    -- (monitor hotplug); re-run on hl.on("monitor.added") if that bites.
    hl.exec_cmd("xrandr --output " .. require('variables').monitor1 .. " --primary")
    -- wallpaper.sh (hyprpaper + themegen, Linux Rising-era) retired: it
    -- fought DMS's own WallpaperBackground.qml for the background layer
    -- and overwrote wallpaper picks with a random one on every login. DMS
    -- now owns wallpaper + matugen theming end to end (SUPER+w).
end)
