#!/usr/bin/env bash
# Opens/closes the startup widget group (fastfetch, cava, tty-clock,
# terminal-rain) together -- called from autostart.lua and SUPER+G.
set -euo pipefail

CLASSES=(widget-fastfetch widget-cava widget-clock widget-rain)

open_classes=$(hyprctl clients -j | jq -r '.[].class')

any_open=0
for c in "${CLASSES[@]}"; do
    grep -qx "$c" <<<"$open_classes" && any_open=1 && break
done

if [[ "$any_open" == 1 ]]; then
    for c in "${CLASSES[@]}"; do
        hyprctl clients -j | jq -r --arg c "$c" '.[] | select(.class == $c) | .address' |
            while read -r addr; do
                hyprctl dispatch closewindow "address:$addr"
            done
    done
else
    # alt-screen avoids kitty scrolling on fastfetch's tall output;
    # cursor hidden since `read` just holds the window open, never reads.
    kitty --class widget-fastfetch -e sh -c \
        "printf '\033[?1049h'; fastfetch --config ~/.config/fastfetch/widget.jsonc; printf '\033[?25l'; read" &
    kitty --class widget-cava -e cava &
    kitty --class widget-clock -e tty-clock -c -C 6 &
    kitty --class widget-rain -e terminal-rain --rain-color white -t --lightning-color cyan --speed medium &
fi
