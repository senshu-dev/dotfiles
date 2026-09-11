# 20-packages.sh — package installation.

# Packages installed with pacman (one per line makes diffs clean).
PACMAN_PACKAGES=(
    zsh
    zip
    unzip
    uwsm
    go                  # builds dms (dank-shell core), scripts/40-config.sh
    make
    playerctl
    brightnessctl
    quickshell
    slurp
    cliphist
    grim
    wf-recorder        # sidebar recording tile
    hyprpolkitagent
    xdg-desktop-portal-hyprland
    hyprlock
    hyprsunset
    hypridle
    mpv
    imv                # default image viewer (screenshot tile, nautilus)
    yay
    qt6-5compat
    libcanberra        # canberra-gtk-play: volume-change blip in the sidebar
    pacman-contrib     # checkupdates: sidebar update-count tile
    socat              # sidebar submap indicator: reads the Hyprland event socket
    nautilus
    gvfs               # trash, mounting drives, network shares
    file-roller        # archive extract/create integration
    tumbler            # thumbnailing service
    ffmpegthumbnailer  # video thumbnails for tumbler
    nautilus-python    # base for python nautilus extensions
    libnetfilter_queue
    bluez              # bluetoothd; services/Bluetooth.qml talks to it over D-Bus
    bluez-utils        # bluetoothctl (CLI), bluetuith's backend
    matugen            # wallpaper -> Material You palette; dms shells out to it directly
    adw-gtk-theme      # adw-gtk3/adw-gtk3-dark; dms flips gtk-theme via gsettings on theme change
)

AUR_PACKAGES=(
    hyprqt6engine
    hyprmod
    nautilus-open-any-terminal  # "Open Terminal Here" -> kitty
    bluetuith                   # TUI bluetooth manager, sidebar bluetooth tile left-click
    tty-clock
    terminal-rain-lightning
)

setup_pacman_packages() {
    info "Installing packages with pacman"
    sudo pacman -S --noconfirm "${PACMAN_PACKAGES[@]}"
    ok "Packages installed"
}

setup_aur_packages() {
    info "Installing AUR packages with yay"
    yay -S --noconfirm "${AUR_PACKAGES[@]}"
    ok "AUR packages installed"
}

setup_packages() {
    setup_pacman_packages
    setup_aur_packages
}
