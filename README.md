# dotfiles

[CachyOS](https://cachyos.org/) + Hyprland desktop, provisioned by a set of
shell scripts and themed by a [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)
fork running on [Quickshell](https://quickshell.org/).

> **Targets CachyOS**, not vanilla Arch. A couple of provisioning steps rely
> on CachyOS-only packages/repos (mirror ranking via `cachyos-rate-mirrors`,
> the `yay` AUR helper being directly `pacman`-installable, the optional
> `gaming` extra's `cachyos-gaming-meta`). Most of the rest is
> distro-agnostic Arch shell scripting and should work on stock Arch too,
> but this hasn't been verified there.
>
> Assumes **Hyprland, kitty, and SDDM are already installed** — none of the
> provisioning steps install them. Pick CachyOS's Hyprland edition (or the
> minimal/no-DE installer option with Hyprland + kitty + SDDM selected) so
> they're present before running `setup.sh`.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/senshu-dev/dotfiles/main/setup.sh | bash
```

This clones the repo to a temp directory and runs every provisioning step in
order (mirrors, packages, shell, config, fonts, extras). Safe to re-run.

To run only some steps, clone the repo yourself and pass step names:

```bash
git clone https://github.com/senshu-dev/dotfiles.git && cd dotfiles
./setup.sh config fonts   # e.g. just reinstall config + fonts
./setup.sh --list         # list all step names
./setup.sh --help
```

## What's here

- **`setup.sh` + `scripts/NN-*.sh`** — provisioning for a fresh CachyOS
  install: mirrors, packages, shell, dotfiles, fonts, optional extras.
- **`.config/hypr/`** — Hyprland config, written in **Lua** (`hl.*` API)
  rather than the classic `hyprland.conf` syntax. This is Hyprland's own
  native config format since 0.55 (May 2026) — `hyprland.lua` auto-loads
  instead of `hyprland.conf` if present, no patched build or extra package
  required.
- **`.config/dank-shell/`** — a git submodule fork of
  [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell),
  deployed as the live desktop shell (top bar, dock, wallpaper/theme picker,
  notifications, control center, ...). See "DankMaterialShell fork
  submodule" below.
- **`.config/kitty/`** — terminal config with theme sync.
- **`qylock-sddm.sh`** — standalone SDDM login-theme manager (not part of the
  automated setup; run manually when wanted).

## Provisioning steps

| Step | What it does |
|---|---|
| `mirrors` | Rank both the Arch and CachyOS mirrorlists (`cachyos-rate-mirrors`) |
| `update` | `pacman -Syyu` |
| `packages` | Install pacman + AUR packages (Hyprland, Quickshell, kitty, nautilus, bluez, ...) |
| `remove` | Remove unwanted defaults (Dolphin) and set Nautilus as the default file manager |
| `shell` | Install zsh + oh-my-zsh, set as default shell |
| `config` | Copy `.config/` into `~/.config/` |
| `fonts` | Install the AnnotationMono font |
| `extras` | Interactive menu (see below) |

### Extras menu

An interactive checklist (`SPACE` toggle, arrows move, `ENTER` install, `q`
quit; everything installs if run non-interactively, e.g. piped from curl):

| Extra | What it installs |
|---|---|
| `zen` | Zen Browser (downloaded release tarball, not packaged) |
| `bluetooth` | Enables & starts `bluetooth.service` (packages are installed unconditionally; the service is opt-in) |
| `vscode` | VS Code Insiders (AUR) |
| `podman` | `podman` + `podman-compose`, plus a `docker` → `podman` shim at `/usr/local/bin/docker` so tools that hardcode `docker` keep working |
| `binenv` | [binenv](https://github.com/devops-works/binenv) (official install script) — a version manager for CLI binaries |
| `k9s` | Kubernetes TUI (AUR) |
| `gaming` | CachyOS gaming meta packages — **requires the [CachyOS repo](https://wiki.cachyos.org/cachyos_repo/) already added to `pacman.conf`**, not part of vanilla Arch |

## Hyprland config (`.config/hypr/`)

Written in Lua (`hl.*` config API) rather than plain `hyprland.conf`:

- **`variables.lua`** — every user-tunable value in one place: launched
  programs, the mod key, and the two monitor output names driving
  `rules.lua`'s workspace assignment and the workspace-cycling keybinds.
  Update this file (and the monitor names specifically) when moving to a
  new machine or monitor layout.
- **`monitor.lua`**, **`hyprenv.lua`**, **`hyprland.lua`**, **`visual.lua`**,
  **`keybindings.lua`**, **`rules.lua`**, **`autostart.lua`** — one concern
  per file, all `require`d from `hyprland.lua`.
- **`hyprlock.conf`** / **`hypridle.conf`** — lock screen + idle timeouts.
  `hyprlock.conf`'s colors are generated (see Theming below), not hand-tuned.
- **`scripts/`** — small helper scripts: workspace cycling, theme sync for
  kitty/GTK/hyprlock, light/dark variant switching.

### Keybindings

Mod key is `SUPER` (defined in `variables.lua`).

| Bind | Action |
|---|---|
| `SUPER + Backspace` | Terminal |
| `SUPER + Space` | App launcher |
| `SUPER + E` | File manager |
| `SUPER + L` | Lock screen |
| `SUPER + T` | Theme switcher (radial menu) |
| `SUPER + P` | Power menu |
| `SUPER + V` | Clipboard history |
| `SUPER + C` / `SUPER + Q` | Close window |
| `SUPER + D` | Fullscreen (mode 1) |
| `SUPER + F` | Fullscreen |
| `SUPER + B` | Pseudo-tile |
| `SUPER + J` | Toggle split direction |
| `SUPER + Alt + Space` | Toggle floating |
| `ALT + Tab` | Cycle windows |
| `ALT + Space` then arrows | Directional focus submap (`Esc` to exit) |
| `SUPER + [1-8]` | Go to workspace N |
| `SUPER + Left/Right` | Cycle main monitor's workspaces 1→2→3→4→1 (wraps, even through empty ones) |
| `SUPER + Alt + Left/Right` | Same, for the second monitor's workspaces (5-8) |
| `SUPER + Escape` | Reload Hyprland config |
| `Print` / `SUPER + S` | Region screenshot → clipboard + file |
| Mouse: `SUPER + drag/resize` | Move / resize windows |
| `XF86Audio*`, `XF86MonBrightness*` | Volume, mute, brightness (hardware keys) |

### Gaming performance rules

Any window classed `steam_app_*` or matching `*game*` (case-insensitive)
gets: workspace 1, forced fullscreen, zero animation/blur/shadow/rounding,
full opacity, and tearing enabled. Verified against a real Steam title;
window-open-time properties (workspace, fullscreen) only apply to windows
opened *after* the rule is loaded, not already-running ones.

## DankMaterialShell fork submodule

`.config/dank-shell` is a git submodule (the DankMaterialShell fork this
project is built on). After cloning or pulling this repo, run:

```bash
git submodule update --init --recursive
```

The Go daemon binary is gitignored and must be built, not copied:

```bash
cd .config/dank-shell/core && make
```

`.config/dank-shell/quickshell/DankCommon` is a symlink to `../dank-qml-common/DankCommon`
(`dank-qml-common` is a second, nested git submodule) — when deploying the
QML tree elsewhere (see below), the sibling `dank-qml-common` directory must
be copied alongside it, not just `quickshell/` alone, or that symlink dangles.

## Deployed as the live shell

The fork is deployed as the live shell: `~/.config/quickshell` is a plain
copy of `.config/dank-shell/quickshell` (plus a sibling `~/.config/dank-qml-common`,
see the symlink note above), launched directly from `~/.config/hypr/autostart.lua`
(`dms run --config ~/.config/quickshell`) rather than via the staged
`~/.config/systemd/user/dms.service` unit — that unit requires
`graphical-session.target`, which this host's systemd user session never
activates (`Requisite=graphical-session.target` fails every start; a
pre-existing gap, not something this deploy fixed).

### Rolling back the TopBar/plugins deploy

If the deployed shell misbehaves, restore the pre-deploy backup:

```bash
pkill -f 'dms run --config'   # or: kill the PID from `pgrep -f "dms run --config"`
rm -rf ~/.config/quickshell
mv ~/.config/quickshell-backup-pre-topbar-plugins-<timestamp> ~/.config/quickshell
```

Replace `<timestamp>` with the actual backup directory name
(`ls ~/.config | grep quickshell-backup-pre-topbar-plugins`). Also revert
`~/.config/hypr/autostart.lua`'s `dms run` line back to `quickshell` (or
`git checkout` that file to the pre-deploy commit) and re-run
`hyprctl reload` / restart Hyprland so the old shell relaunches on next
session start.

## Development

Quickshell itself only runs under a real Wayland/Hyprland session (layer-shell
app) — there's no way to preview it outside one. Useful IPC toggles while
running (`dms ipc call --help` / `.config/dank-shell/docs/IPC.md` for the
full list):

```bash
qs ipc call launcher toggle
qs ipc call thememenu toggle
qs ipc call powermenu toggle
qs ipc call clipboard toggle
qs ipc call dash toggle wallpaper
```

The dank-shell submodule has its own Go test suite (`cd .config/dank-shell/core && go test ./...`).

## VS Code profile (`.config/vscode.code-profile`)

An exported VS Code profile (settings, keybindings, extension list, theme) —
not auto-applied by the `config` step, since VS Code doesn't read profiles
from `~/.config` automatically. Import it manually: Command Palette →
"Profiles: Import Profile..." → select the file, or
`code --import-profile .config/vscode.code-profile`.

## SDDM theming (`qylock-sddm.sh`)

A standalone CLI for managing [qylock](https://github.com/Darkkal44/qylock)
SDDM themes — not part of the automated setup, run manually:

```bash
./qylock-sddm.sh list             # list themes, marking installed/current
./qylock-sddm.sh install <theme>  # download (if needed) and activate
```
