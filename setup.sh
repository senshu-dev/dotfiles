#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$SCRIPT_DIR/config"

info()      { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
success()   { printf '\033[1;32m[OK]\033[0m   %s\n' "$*"; }
warn()      { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }
error()     { printf '\033[1;31m[ERR]\033[0m  %s\n' "$*" >&2; }

link_config() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [[ -L "$dst" ]]; then
        rm "$dst"
    elif [[ -e "$dst" ]]; then
        local bak="$dst.bak.$(date +%s)"
        warn "$dst exists, backing up to $bak"
        mv "$dst" "$bak"
    fi
    ln -sf "$src" "$dst"
    success "$dst -> $src"
}

setup_hypr() {
    info "Linking Hyprland config..."
    link_config "$CONFIG_SRC/hypr" "$HOME/.config/hypr"
}

setup_kitty() {
    info "Linking kitty config..."
    link_config "$CONFIG_SRC/kitty" "$HOME/.config/kitty"
}

setup_caelestia() {
    info "Linking Caelestia config..."
    link_config "$CONFIG_SRC/caelestia/shell.json" "$HOME/.config/caelestia/shell.json"
}

setup_all() {
    setup_hypr
    setup_kitty
    setup_caelestia
    echo
    success "All configs linked. Run 'hyprctl reload' to apply Hyprland changes."
}

usage() {
    cat <<EOF
Usage: $0 [component...]

Components:
  hypr        Hyprland config
  kitty       kitty terminal config
  caelestia   Caelestia shell config

With no arguments, links all configs.
EOF
}

if [[ $# -eq 0 ]]; then
    setup_all
    exit 0
fi

for arg in "$@"; do
    case "$arg" in
        hypr)       setup_hypr ;;
        kitty)      setup_kitty ;;
        caelestia)  setup_caelestia ;;
        --help|-h)  usage; exit 0 ;;
        *)          error "Unknown component: $arg"; usage; exit 1 ;;
    esac
done
