# 25-defaults.sh — set app defaults, enable services.

setup_defaults() {
    info "Setting default apps and enabling services"

    # Nautilus as the default file manager.
    if command -v xdg-mime &>/dev/null; then
        xdg-mime default org.gnome.Nautilus.desktop inode/directory
        ok "Default file manager set to Nautilus"

        # imv as the default image viewer — Nautilus otherwise has no app
        # registered for image mimetypes.
        for mime in image/png image/jpeg image/gif image/webp image/bmp; do
            xdg-mime default imv.desktop "$mime"
        done
        ok "Default image viewer set to imv"
    else
        warn "xdg-mime not found; skipped setting default file manager"
    fi

    # Point nautilus-open-any-terminal's "Open Terminal Here" at kitty.
    if gsettings list-schemas 2>/dev/null | grep -q nautilus-open-any-terminal; then
        gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal kitty
        ok "Nautilus 'Open Terminal Here' set to kitty"
    fi

    # Fresh installs have no display manager enabled at all; idempotent on
    # hosts that already have it enabled.
    sudo systemctl enable sddm.service
    ok "sddm.service enabled"
}
