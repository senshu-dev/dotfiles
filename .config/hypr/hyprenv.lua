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
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("GBM_BACKEND", "nvidia-drm")

-- NVIDIA (RTX 5060 Ti) env vars for the future main desktop -- commented out
-- since this file is shared with the AMD-only laptop/VM and GBM_BACKEND=
-- nvidia-drm would break rendering entirely on non-NVIDIA hardware. Uncomment
-- (host-guarded, once that machine's hostname is known) when it's provisioned.
-- hl.env("__GL_GSYNC_ALLOWED", "1")   -- only if the monitor is G-Sync capable
-- hl.env("__GL_VRR_ALLOWED", "1")
-- also requires nvidia_drm.modeset=1 as a kernel param (bootloader/mkinitcpio,
-- not something this file can set).