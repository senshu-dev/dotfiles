-- binenv shims must be on PATH for every app Hyprland spawns (launchers,
-- VS Code, etc.) -- Hyprland starts under SDDM with the bare system PATH and
-- doesn't import shell rc files or systemd environment.d, so this has to be
-- set here explicitly.
hl.env("PATH", os.getenv("HOME") .. "/.local/bin:" .. os.getenv("HOME") .. "/.binenv:" .. os.getenv("PATH"))

hl.env("XCURSOR_SIZE", "26")
hl.env("HYPRCURSOR_SIZE", "26")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "hyprqt6engine")
-- GTK_THEME is intentionally NOT set: a hardcoded value overrides gsettings,
-- which is what DMS's own matugen GTK templates drive for light/dark switching.
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
-- Qt 6's image-bomb guard defaults to 256MiB decoded-size and silently
-- drops anything over it ("QImageIOHandler: Rejecting image..."), which
-- broke DMS's own WallpaperBackground on some of ~/walls' larger images.
hl.env("QT_IMAGEIO_MAXALLOC", "1024")

-- No NVIDIA/GBM env vars here -- this host is AMD-only (Lucienne iGPU); the
-- desktop's NVIDIA vars live in hosts/desktop/hypr/hyprenv.lua instead.
