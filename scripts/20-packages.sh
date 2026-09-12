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
    neovim             # tracked for reproducibility; already on this host
    sshfs              # nvim remote workflow: mount remote dirs, edit with full local LSP
    ripgrep            # telescope live_grep backend
    fd                 # telescope find_files backend
    tree-sitter-cli    # nvim-treesitter parser installs
    gopls              # nvim LSP: Go
    pyright            # nvim LSP: Python
    bash-language-server    # nvim LSP: Bash
    yaml-language-server    # nvim LSP: YAML (k8s/Helm schemas)
    dockerfile-language-server  # nvim LSP: Dockerfile
    lua-language-server     # nvim LSP: Lua (editing this config)
    arduino-cli         # Arduino/ESP: board cores, sketch scaffolding, compile db
    clang               # provides clangd; nvim LSP for .ino (Arduino/ESP) via arduino-cli's compile_commands.json
    jq                  # scripts/40-config.sh: idempotent settings.json patch
)

AUR_PACKAGES=(
    hyprqt6engine
    hyprmod
    nautilus-open-any-terminal  # "Open Terminal Here" -> kitty
    bluetuith                   # TUI bluetooth manager, sidebar bluetooth tile left-click
    tty-clock
    terminal-rain-lightning
    terraform-ls        # nvim LSP: Terraform
    helm-ls              # nvim LSP: Helm
)

setup_pacman_packages() {
    info "Installing packages with pacman"
    sudo pacman -S --noconfirm "${PACMAN_PACKAGES[@]}"
    ok "Packages installed"
}

setup_aur_packages() {
    info "Installing AUR packages with yay"
    # --nocheck: helm-ls's PKGBUILD runs network-dependent integration
    # tests in check() that fail in a sandboxed build (confirmed on this
    # host); skipping tests doesn't affect the built binary, only the
    # packager's own pre-install verification.
    yay -S --noconfirm --mflags --nocheck "${AUR_PACKAGES[@]}"
    ok "AUR packages installed"
}

setup_packages() {
    setup_pacman_packages
    setup_aur_packages
}
