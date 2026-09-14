# Hyprland config (`.config/hypr/`)

Written in Lua (`hl.*` config API) rather than plain `hyprland.conf`:

- **`variables.lua`** — every user-tunable value in one place: launched
  programs, the mod key, and the two monitor output names driving
  `rules.lua`'s workspace assignment and the workspace-cycling keybinds.
  Update this file (and the monitor names specifically) when moving to a
  new machine or monitor layout.
- **`monitor.lua`**, **`hyprenv.lua`**, **`hyprland.lua`**, **`visual.lua`**,
  **`keybindings.lua`**, **`gestures.lua`**, **`rules.lua`**,
  **`autostart.lua`** — one concern per file, all `require`d from
  `hyprland.lua`.
- **`hypridle.conf`** — idle timeouts + `loginctl lock-session` signalling.
  Lock screen itself is owned by the DankMaterialShell fork now, not a
  file in this repo.
- **`scripts/`** — small helper scripts: workspace cycling, theme sync for
  kitty/GTK, light/dark variant switching, `xray-instance.sh` (VPN tunnel
  control, see below).

## Keybindings

Mod key is `SUPER` (defined in `variables.lua`).

| Bind | Action |
|---|---|
| `SUPER + Backspace` | Terminal |
| `SUPER + Space` | App launcher |
| `SUPER + E` | File manager |
| `CTRL + ALT + L` | Lock screen |
| `SUPER + T` | Theme switcher (radial menu) |
| `SUPER + P` | Power menu |
| `SUPER + V` | Clipboard history |
| `SUPER + C` / `SUPER + Q` | Close window |
| `SUPER + F` | Fullscreen |
| `SUPER + M` | Maximize (fullscreen mode 1, keeps bar/borders) |
| `SUPER + B` | Pseudo-tile |
| `SUPER + Alt + Space` | Toggle floating |
| `ALT + Tab` | Cycle windows |
| `SUPER + [1-8]` | Go to workspace N |
| `SUPER + Left/Right` | Cycle main monitor's workspaces 1→2→3→4→1 (wraps, even through empty ones) |
| `SUPER + Alt + Left/Right` | Same, for the second monitor's workspaces (5-8) |
| `SUPER + Escape` | Reload Hyprland config |
| `Print` / `SUPER + S` | Region screenshot → clipboard + file |
| Mouse: `SUPER + drag/resize` | Move / resize windows |
| `XF86Audio*`, `XF86MonBrightness*` | Volume, mute, brightness (hardware keys) |

Layout is Hyprland's native `scrolling` (niri-style infinite horizontal
tape of columns), set via `general.layout` in `hyprland.lua`:

| Bind | Action |
|---|---|
| `SUPER + H` / `SUPER + L` | Focus column left / right (scrolls into view) |
| `SUPER + J` / `SUPER + K` | Focus window down / up within the current column |
| `SUPER + Shift + H` / `SUPER + Shift + L` | Swap current column left / right |
| `SUPER + Minus` / `SUPER + Equal` | Shrink / grow current column width |

Hyprtasking's overview panning (`tasking.lua`) uses `SUPER + Comma` (pan
left), `SUPER + Shift + Comma` / `SUPER + Shift + Period` (move window left
/ right in the overview) — moved off h/l to make room for the above.

## Touchpad gestures (`gestures.lua`)

Two-finger vertical swipe is left unbound on purpose — with nothing
claiming it, it's plain libinput two-finger scroll. Scroll speed itself is
tuned down from Hyprland's default via `input.touchpad.scroll_factor`
(`hyprland.lua`, `0.3`).

| Gesture | Action |
|---|---|
| 2-finger left/right | Pan the scrolling-layout tape (native `scroll_move`) |
| 2-finger pinch (any angle) | Resize focused window — spread to grow, pinch to shrink |
| 3-finger left/right | Cycle workspaces (same wraparound logic as `SUPER + Left/Right`, auto-detects the focused monitor) |
| 3-finger up | Fullscreen |
| 3-finger down | Float |

## xray-instance.sh (Xray-core VPN tunnel)

`hypr/scripts/xray-instance.sh start|stop|status [tun|proxy]` runs an
[Xray-core](https://github.com/XTLS/Xray-core) VLESS tunnel as a transient
`systemd --user` unit. `tun` is full system-wide capture via Xray's own
native tun inbound (no NetworkManager/polkit setup); `proxy` is local
SOCKS5 (`10808`)/HTTP (`10809`) inbounds + the GNOME system-proxy gsetting.
`start` always stops the opposite mode first — the two don't stack.

Its config files are **deliberately not in this repo** (they hold bare VLESS
credentials) — create them yourself at:

- `~/.local/state/xray-instance/tun-config.json`
- `~/.local/state/xray-instance/proxy-config.json`

Template for `tun-config.json`:

```json
{
  "inbounds": [
    {
      "protocol": "tun",
      "settings": {
        "name": "xray-tun0",
        "mtu": 1500,
        "autoSystemRoutingTable": ["0.0.0.0/0", "::/0"],
        "autoOutboundsInterface": "auto"
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "your-server.example.com",
            "port": 443,
            "users": [
              { "id": "<VLESS UUID>", "encryption": "none", "flow": "xtls-rprx-vision" }
            ]
          }
        ]
      },
      "streamSettings": { "network": "tcp", "security": "reality", "realitySettings": {} }
    }
  ]
}
```

`proxy-config.json` is the same `outbounds` block, with `inbounds` swapped
for local SOCKS/HTTP listeners instead of `tun` (ports must match
`SOCKS_PORT`/`HTTP_PORT` in the script, `10808`/`10809`):

```json
{
  "inbounds": [
    { "protocol": "socks", "port": 10808, "listen": "127.0.0.1" },
    { "protocol": "http", "port": 10809, "listen": "127.0.0.1" }
  ],
  "outbounds": [ /* same VLESS outbound as tun-config.json */ ]
}
```

`streamSettings` (`security`/`realitySettings`/`tlsSettings`/`flow`) depends
on what your VLESS server actually offers — copy those fields from whatever
your VPN provider gives you, the shape above is just Reality as an example.

## Gaming performance rules

Any window classed `steam_app_*` or matching `*game*` (case-insensitive)
gets: workspace 1, forced fullscreen, zero animation/blur/shadow/rounding,
full opacity, and tearing enabled. Verified against a real Steam title;
window-open-time properties (workspace, fullscreen) only apply to windows
opened *after* the rule is loaded, not already-running ones.
