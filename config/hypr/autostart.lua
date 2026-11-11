hl.on("hyprland.start", function ()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &")
    hl.exec_cmd("/usr/lib/soteria-polkit/soteria")
    hl.exec_cmd("wl-paste --watch cliphist store &")
    hl.exec_cmd("caelestia shell -d")
    hl.exec_cmd("caelestia scheme set -n dynamic")
    -- XWayland picks the first output as primary; without this, Wine/Proton games
    -- see HDMI-A-2 (75Hz) as monitor 0 and DXVK caps at 75fps on DP-6 fullscreen.
    hl.exec_cmd("bash -c 'sleep 1 && xrandr --output DP-6 --primary' &")
    -- NVIDIA + DP timing fix: re-apply monitor config after GPU fully initializes
    hl.exec_cmd("hyprpm reload -n")
    hl.exec_cmd("bash -c 'sleep 2 && hyprctl reload' &")
end)
