# 20-packages.sh — package installation.

# Packages installed with pacman (one per line makes diffs clean).
PACMAN_PACKAGES=(
    base-devel          # fakeroot/gcc/patch/... -- makepkg ships with pacman itself, but
                        # actually building anything (yay, AUR_PACKAGES below) needs this
                        # group too, and a fresh no-package CachyOS install doesn't have it
    zsh
    zip
    unzip
    uwsm
    go                  # builds dms (dank-shell core), scripts/40-config.sh
    make
    playerctl
    brightnessctl
    cava               # DMS's CavaService.qml shells out to this for the audio-visualizer widget
    hyprland
    hyprpm              # split out of the hyprland package as of 0.56.2-3;
                        # autostart.lua's `hyprpm reload -n` and hyprtasking
                        # (extras) need the binary
    kitty
    sddm
    quickshell
    slurp
    grim
    satty              # screenshot annotation (swappy successor); bind over grim+slurp
    xdg-desktop-portal-hyprland
    hypridle
    fzf
    zoxide
    mpv
    imv                # default image viewer (screenshot tile, nautilus)
    yay
    qt6-5compat
    pacman-contrib     # checkupdates: DMS's update-count tile (core/internal/server/sysupdate)
    nautilus
    gvfs               # trash, mounting drives, network shares
    file-roller        # archive extract/create integration
    tumbler            # thumbnailing service
    ffmpegthumbnailer  # video thumbnails for tumbler
    nautilus-python    # base for python nautilus extensions
    libnetfilter_queue # zapret2 (DPI-bypass tool, unmanaged by this repo) needs this for its nfqws tun queue
    bluez              # bluetoothd; services/Bluetooth.qml talks to it over D-Bus
    bluez-utils        # bluetoothctl CLI
    matugen            # wallpaper -> Material You palette; dms shells out to it directly
    adw-gtk-theme      # adw-gtk3/adw-gtk3-dark; dms flips gtk-theme via gsettings on theme change
    qt6-declarative    # qylock-sddm.sh: Qt6 SDDM themes (most qylock themes)
    qt6-svg            # qylock-sddm.sh: Qt6 SDDM themes, SVG assets
    qt6-multimedia          # qylock-sddm.sh: themes with video backgrounds
    qt6-multimedia-ffmpeg   # qylock-sddm.sh: ffmpeg backend for qt6-multimedia
    gst-plugins-base   # qylock-sddm.sh: video playback backend
    gst-plugins-good   # qylock-sddm.sh: video playback backend
    gst-plugins-bad    # qylock-sddm.sh: video playback backend
    gst-plugins-ugly   # qylock-sddm.sh: video playback backend
    neovim             # tracked for reproducibility; already on this host
    fastfetch          # tracked for reproducibility; ships by default on CachyOS
    ripgrep            # nvim's default :grep backend
    jq                  # hypr/scripts/cycle-workspace.sh: focused-monitor lookup
)

AUR_PACKAGES=(
    google-chrome        # .config/chrome-flags.conf: native Wayland
    hyprqt6engine
    hyprmod
    nautilus-open-any-terminal  # "Open Terminal Here" -> kitty
)

# Sources hosts/<host>/packages.sh (if it exists) for HOST_PACMAN_PACKAGES /
# HOST_AUR_PACKAGES, and appends them to the common lists above.
load_host_packages() {
    local scripts_dir host_packages_file
    scripts_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    host_packages_file="$scripts_dir/../hosts/$(detect_host)/packages.sh"
    HOST_PACMAN_PACKAGES=()
    HOST_AUR_PACKAGES=()
    [[ -f "$host_packages_file" ]] && source "$host_packages_file"
    PACMAN_PACKAGES+=("${HOST_PACMAN_PACKAGES[@]}")
    AUR_PACKAGES+=("${HOST_AUR_PACKAGES[@]}")
}

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
    load_host_packages
    setup_pacman_packages
    setup_aur_packages
}
