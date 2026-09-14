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
> Runs on a bare CachyOS install with the "no desktop" / no-packages option
> picked at install time — `packages` installs Hyprland, kitty, and SDDM
> itself, and `defaults` enables `sddm.service`, rather than assuming any
> of that is already there.

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
  rather than the classic `hyprland.conf` syntax. See
  [`docs/hyprland.md`](docs/hyprland.md) for the file layout, keybindings,
  touchpad gestures, the Xray VPN tunnel script, and the gaming rules.
- **`.config/dank-shell/`** — a git submodule fork of
  [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell),
  deployed as the live desktop shell (top bar, dock, wallpaper/theme picker,
  notifications, control center, ...). See
  [`docs/dank-shell.md`](docs/dank-shell.md).
- **`.config/kitty/`** — terminal config with theme sync.
- **`.config/nvim/`** — hand-rolled Neovim config (`lazy.nvim`, no distro
  like LazyVim/NvChad), themed live from the desktop's matugen palette. See
  [`docs/neovim.md`](docs/neovim.md).
- **`qylock-sddm.sh`** — standalone SDDM login-theme manager (not part of the
  automated setup; run manually when wanted). See
  [`docs/qylock.md`](docs/qylock.md).
- **`.config/vscode.code-profile`** — an exported VS Code profile (settings,
  keybindings, extensions, theme), imported manually: Command Palette →
  "Profiles: Import Profile..." → select the file, or
  `code --import-profile .config/vscode.code-profile`. Not auto-applied by
  the `config` step — VS Code doesn't read profiles from `~/.config`.

## Provisioning steps

| Step | What it does |
|---|---|
| `mirrors` | Rank both the Arch and CachyOS mirrorlists (`cachyos-rate-mirrors`) |
| `update` | `pacman -Syyu` |
| `packages` | Install pacman + AUR packages (Hyprland, SDDM, kitty, Quickshell, nautilus, bluez, ...) |
| `defaults` | Set Nautilus/imv/kitty as default file manager/image viewer/terminal, enable `sddm.service` |
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
| `xray` | [Xray-core](https://github.com/XTLS/Xray-core) (built from source, pinned commit), `cap_net_admin` granted for tun mode. Driven by `hypr/scripts/xray-instance.sh`, see [`docs/hyprland.md`](docs/hyprland.md) |
| `office` | LibreOffice (`libreoffice-fresh`) + `hunspell-en_us`/`hunspell-ru` spellcheck, `ttf-liberation` (Word/Excel-compatible fonts), `evince` (PDF viewer) |

## Docs

- [`docs/hyprland.md`](docs/hyprland.md) — config file layout, keybindings,
  touchpad gestures, `xray-instance.sh`, gaming performance rules
- [`docs/neovim.md`](docs/neovim.md) — keybindings, commands, plugin
  architecture
- [`docs/dank-shell.md`](docs/dank-shell.md) — submodule setup, live deploy,
  rollback
- [`docs/qylock.md`](docs/qylock.md) — SDDM theme management
