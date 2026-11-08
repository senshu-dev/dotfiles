#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

read_packages() {
    sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$1"
}

echo "==> Initializing submodules..."
git -C "$DOTFILES_DIR" submodule update --init --recursive

echo "==> Updating system..."
sudo pacman -Syu --noconfirm

echo "==> Installing pacman packages..."
read_packages "$DOTFILES_DIR/packages/pacman.txt" | xargs sudo pacman -S --needed --noconfirm

if ! command -v paru &>/dev/null; then
    echo "==> Building paru..."
    PARU_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/paru.git "$PARU_DIR"
    (cd "$PARU_DIR" && makepkg -si --noconfirm)
    rm -rf "$PARU_DIR"
fi

echo "==> Installing AUR packages..."
read_packages "$DOTFILES_DIR/packages/aur.txt" | xargs paru -S --needed --noconfirm

echo "==> Enabling services..."
sudo systemctl enable sddm.service bluetooth.service

echo "==> Done! Run ./setup.sh to link configs."
