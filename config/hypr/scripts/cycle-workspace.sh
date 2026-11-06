#!/usr/bin/env bash
# Cycle the focused monitor's workspace within its assigned range,
# wrapping numerically (e.g. 1→2→3→4→1).
#
# Usage: cycle-workspace.sh <+1|-1>
#
# The range is derived from Hyprland workspace rules — whichever workspaces
# are bound to the focused monitor form the cycle range.
set -euo pipefail

dir="$1"

focused=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
cur=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .activeWorkspace.id')

read -r start end < <(
    hyprctl workspacerules -j | jq -r --arg mon "$focused" '
        [.[] | select(.monitor == $mon) | .workspaceString | tonumber] | sort | "\(first) \(last)"
    '
)

if [[ -z "$start" || -z "$end" ]]; then
    exit 0
fi

span=$((end - start + 1))

if (( cur < start || cur > end )); then
    next=$start
else
    next=$(( (cur - start + dir + span) % span + start ))
fi

hyprctl eval "
hl.dispatch(hl.dsp.focus({ monitor = \"$focused\" }))
hl.dispatch(hl.dsp.focus({ workspace = $next }))
"
