#!/usr/bin/env bash
# Cycle <monitor>'s active workspace within [start,end], wrapping numerically
# (1-2-3-1) regardless of whether the target workspace has windows -- unlike
# Hyprland's built-in +1/-1 which is occupancy-aware.
#
# Args (explicit, used by keybindings.lua):
#   <monitor> <start> <end> <+1|-1>
# Args (auto-detect, used by gestures.lua -- a touchpad swipe has no
# "which monitor" the way a keybind does):
#   --auto <+1|-1> <monitor:start:end> [<monitor:start:end> ...]
#   Cycles whichever monitor currently has focus, picking its range from
#   the given monitor:start:end pairs; no-ops if the focused monitor isn't
#   one of them.
set -euo pipefail

if [[ "${1:-}" == "--auto" ]]; then
    dir="$2"; shift 2
    focused=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
    found=0
    for pair in "$@"; do
        IFS=: read -r mon start end <<<"$pair"
        [[ "$mon" == "$focused" ]] || continue
        found=1
        set -- "$mon" "$start" "$end" "$dir"
        break
    done
    # Focused monitor wasn't in the list -- nothing to cycle.
    [[ "$found" == 1 ]] || exit 0
fi

monitor="$1" start="$2" end="$3" dir="$4"

cur=$(hyprctl monitors | awk -v m="$monitor" '
    $0 ~ ("^Monitor " m " ") { f = 1 }
    f && /active workspace:/  { print $3; exit }
')

span=$((end - start + 1))
next=$(( (cur - start + dir + span) % span + start ))
# plain "hyprctl dispatch workspace <id>" gets parsed as Lua on this
# HyprMod build (config is Lua-driven); route through its hl.dsp API instead.
hyprctl dispatch "hl.dsp.focus({ workspace = $next })"
