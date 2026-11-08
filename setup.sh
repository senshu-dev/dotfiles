#!/usr/bin/env bash
#
# Caelestia dotfiles setup. Links config files into ~/.config and sets up
# the shell environment.
#
#   ./setup.sh              run all components
#   ./setup.sh hypr zsh     run only these components
#   ./setup.sh --list       list component names
#   ./setup.sh --help       show this help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$SCRIPT_DIR/config"

# Terminal-aware colors: suppressed when output is piped or redirected.
if [[ -t 1 ]]; then
    CYAN=$'\033[0;36m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' RED=$'\033[0;31m' NC=$'\033[0m'
else
    CYAN='' GREEN='' YELLOW='' RED='' NC=''
fi

highlight() { printf '%b%s%b\n'    "$CYAN"   "$*" "$NC"; }
info()      { printf '%b[ info ]:%b %s\n'  "$CYAN"   "$NC" "$*"; }
ok()        { printf '%b[  ok  ]:%b %s\n'  "$GREEN"  "$NC" "$*"; }
warn()      { printf '%b[ warn ]:%b %s\n'  "$YELLOW" "$NC" "$*" >&2; }
error()     { printf '%b[  err ]:%b %s\n'  "$RED"    "$NC" "$*" >&2; }

# Creates a symlink dst -> src, backing up any existing non-symlink file.
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
    ok "$dst -> $src"
}

# ── Components ────────────────────────────────────────────────────────────────

setup_hypr() {
    info "Linking Hyprland config..."
    link_config "$CONFIG_SRC/hypr" "$HOME/.config/hypr"
}

setup_kitty() {
    info "Linking kitty config..."
    link_config "$CONFIG_SRC/kitty" "$HOME/.config/kitty"
}

setup_caelestia() {
    info "Linking Caelestia shell config..."
    link_config "$CONFIG_SRC/caelestia/shell.json" "$HOME/.config/caelestia/shell.json"
    for mon_dir in "$CONFIG_SRC"/caelestia/monitors/*/; do
        local mon_name
        mon_name="$(basename "$mon_dir")"
        mkdir -p "$HOME/.config/caelestia/monitors/$mon_name"
        link_config "$mon_dir/shell.json" "$HOME/.config/caelestia/monitors/$mon_name/shell.json"
    done
}

setup_uwsm() {
    info "Linking uwsm environment..."
    link_config "$CONFIG_SRC/uwsm/env-hyprland" "$HOME/.config/uwsm/env-hyprland"
}

setup_zsh() {
    info "Setting up zsh..."

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        info "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        warn "oh-my-zsh already installed, skipping"
    fi

    link_config "$CONFIG_SRC/zsh/.zshrc" "$HOME/.zshrc"

    if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
        chsh -s /usr/bin/zsh
        ok "Default shell set to zsh (re-login to apply)"
    fi
}

# ── Dispatch ──────────────────────────────────────────────────────────────────

# Single source of truth: "name|function|description"
COMPONENTS=(
    "hypr|setup_hypr|Hyprland config"
    "kitty|setup_kitty|kitty terminal config"
    "caelestia|setup_caelestia|Caelestia shell config + per-monitor overrides"
    "uwsm|setup_uwsm|uwsm environment (aquamarine workarounds)"
    "zsh|setup_zsh|zsh config + oh-my-zsh"
)

component_fn() {
    local entry name fn
    for entry in "${COMPONENTS[@]}"; do
        IFS='|' read -r name fn _ <<<"$entry"
        [[ "$name" == "$1" ]] && { printf '%s\n' "$fn"; return 0; }
    done
    return 1
}

usage() {
    local entry name desc
    cat <<EOF
Usage: $0 [component ...]

Links dotfiles configs into ~/.config. With no arguments runs all components.

Components:
EOF
    for entry in "${COMPONENTS[@]}"; do
        IFS='|' read -r name _ desc <<<"$entry"
        printf '  %-12s %s\n' "$name" "$desc"
    done
    printf '\nFlags: --list  print component names one per line\n'
}

main() {
    local entry name fn arg

    if [[ $# -eq 0 ]]; then
        highlight "Caelestia dotfiles setup"
        for entry in "${COMPONENTS[@]}"; do
            IFS='|' read -r name fn _ <<<"$entry"
            "$fn"
        done
        echo
        ok "All components linked. Run 'hyprctl reload' to apply Hyprland changes."
        return
    fi

    for arg in "$@"; do
        case "$arg" in
            --help|-h) usage; return ;;
            --list)    printf '%s\n' "${COMPONENTS[@]%%|*}" ;;
            *)
                if ! fn="$(component_fn "$arg")"; then
                    error "Unknown component: $arg"
                    usage
                    exit 1
                fi
                "$fn"
                ;;
        esac
    done
}

main "$@"
