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
    -- line this replaces.
    hl.exec_cmd("dms run --config ~/.config/quickshell")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wl-paste --watch cliphist store &") -- feeds the sidebar clipboard-history tile
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &")
    -- live wallpaperengine scene (heavier, animated) vs. pre-rendered hyprpaper frame
    -- (near-0% idle, see scripts/wallpaper.sh) -- comment one, uncomment the other
    -- hl.exec_cmd("linux-wallpaperengine --disable-mouse --fullscreen-pause-only-active --no-audio-processing -s --disable-parallax --fps 30 --scaling stretch --screen-root DP-1 --bg 3751292466 --screen-root HDMI-A-1 --bg $(ls -d ~/.steam/steam/steamapps/workshop/content/431960/* | xargs -n 1 basename | shuf -n 1)")
    hl.exec_cmd("~/.config/hypr/scripts/wallpaper.sh")
end)
