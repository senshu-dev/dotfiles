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
- **`.config/nvim/`** — hand-rolled Neovim config (`lazy.nvim`, no distro
  like LazyVim/NvChad), themed live from the desktop's matugen palette. See
  "Neovim config" below.
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

## Neovim config (`.config/nvim/`)

### Keybindings

Leader is `Space`. No custom LSP/diagnostic keymaps are defined — this
config relies entirely on Neovim's built-in default LSP keymaps (0.11+).

| Bind | Action |
|---|---|
| `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Live grep (Telescope) |
| `<leader>fb` | List open buffers (Telescope) |
| `<leader>rt` | Open the `claude` CLI in a vertical split terminal |
| `<leader>rm` | Mount a remote host via `sshfs` (`:SshfsMount`) — prompts a host from `~/.ssh/config`, then a remote path |
| `grn` | Rename symbol (built-in LSP default) |
| `gra` | Code action (built-in LSP default) |
| `grr` | Go to references (built-in LSP default) |
| `gri` | Go to implementation (built-in LSP default) |
| `go` / `gO` | Type definition / document symbols (built-in LSP default) |
| `K` | Hover docs (built-in LSP default) |
| `<C-s>` (insert mode) | Signature help (built-in LSP default) |
| `[d` / `]d` | Previous/next diagnostic (built-in default) |
| `<C-space>` (insert) | Trigger completion (blink.cmp default preset) |
| `<Tab>` / `<S-Tab>` (insert, menu open) | Next/previous completion item |
| `<CR>` (insert, menu open) | Accept completion |
| `<C-e>` (insert, menu open) | Cancel completion |

### Commands

| Command | What it does |
|---|---|
| `:ArduinoInit <sketch-name>` | Prompts for a board FQBN, installs the core if missing, creates the sketch, generates `compile_commands.json` for clangd, opens the `.ino` |
| `:ArduinoRegen` | Regenerates `compile_commands.json` for the sketch in the cwd (run after adding `#include`s) |
| `:SshfsMount` | Same as `<leader>rm` |
| `:Lazy` | Plugin manager UI — install/update/clean/profile |
| `:checkhealth` | Diagnose LSP/treesitter/clipboard/etc. setup issues |
| `:LspInfo` | Show which LSP servers are attached to the current buffer |

### Things that need no action from you

- Colorscheme and statusline re-theme automatically whenever the desktop
  wallpaper/theme changes — no `:colorscheme` re-run, no restart.
- Undo history persists across restarts (`undofile`); system clipboard is
  the default register (`"+`/`"*` not needed for normal yank/paste).
- Indent is 4-space by default, 2-space for `yaml`/`json`/`javascript*`/
  `typescript*` filetypes — matches `.config/vscode.code-profile`.

### If something's not working

- LSP servers are installed via pacman/AUR (`scripts/20-packages.sh`), never
  `:Mason` — there is no Mason here. A missing server means installing its
  system package, not running an in-editor installer.
- `helm_ls` specifically needs the `--mflags --nocheck` AUR build path (its
  own integration tests fail sandboxed) — already handled by
  `scripts/20-packages.sh`, just noting it in case a manual AUR build of it
  ever fails.

Plugin manager is [`lazy.nvim`](https://github.com/folke/lazy.nvim)
(auto-bootstraps itself on first launch — no manual install step). One
plugin spec per concern under `lua/plugins/`, loaded via
`require("lazy").setup("plugins", ...)` in `init.lua`. Plugin versions are
pinned in `lazy-lock.json` (checked in — run `:Lazy update` deliberately,
don't let it drift).

`init.lua` load order: `config.options` → `config.keymaps` →
`config.arduino` → `lazy.setup("plugins")` → `config.theme` (colorscheme
must apply last, after plugins are loaded).

- **`lua/config/options.lua`** — leader is `Space`. Notable non-defaults:
  relative numbers off, folding off, line wrap off, `scrolloff = 8`,
  persistent undo (`undofile`), system clipboard (`unnamedplus`), mouse
  enabled everywhere. Indent is 4-space/tabs-expanded by default, with a
  2-space `FileType` autocmd override for `yaml`/`json`/`javascript`/
  `typescript`/`(javascript|typescript)react` — matches the same languages'
  2-space overrides in `.config/vscode.code-profile`, keep both in sync if
  either changes.
- **`lua/config/keymaps.lua`**:
  - `<leader>rt` — opens a vertical split terminal running the `claude` CLI
    (shells out to whatever's on `$PATH`; if `claude` isn't installed you
    just get the shell's normal "command not found", nothing installs it
    for you).
  - `<leader>rm` — `require("config.remote").mount()`, see the remote-mount
    helper below.
- **`lua/config/remote.lua`** (`:SshfsMount`, or `<leader>rm`) — reads
  `Host` entries out of `~/.ssh/config`, prompts you to pick one and give a
  remote path, then `sshfs`-mounts it at `~/mnt/<host>` and `:cd`s there.
  Deploys nothing to the remote host itself — mount-only.
- **`lua/config/arduino.lua`** (`.ino` files are filetype-mapped to `cpp`
  for clangd) — clangd-native Arduino/ESP workflow, no
  `arduino-language-server`:
  - `:ArduinoInit <sketch-name>` — prompts for a board FQBN (e.g.
    `esp32:esp32:esp32`), offers to `arduino-cli core install` it if
    missing, runs `arduino-cli sketch new`, generates
    `compile_commands.json` via `arduino-cli compile
    --only-compilation-database`, drops a `.fqbn` marker file in the
    sketch dir, and opens the `.ino`.
  - `:ArduinoRegen` — reruns the compilation-database step for the sketch
    in the current directory, reading the FQBN back out of its `.fqbn`
    marker (run this after adding new `#include`s).
- **`lua/plugins/lsp.lua`** (`nvim-lspconfig`) — every server is installed
  from pacman/AUR, never `mason.nvim` (this host blocks Mason's installer
  network calls): `gopls`, `terraformls`, `pyright`, `bashls`, `yamlls`,
  `dockerls`, `helm_ls`, `lua_ls`, `clangd`. `yamlls` has schema-store
  enabled with key-ordering checks off; `lua_ls` knows the `vim` global.
  Diagnostics show as virtual text + signs + underline, not on insert.
- **`lua/plugins/completion.lua`** (`saghen/blink.cmp`) — default keymap
  preset, sources are `lsp` + `path` + `buffer`. Wired into
  `lsp.lua` via `require("blink.cmp").get_lsp_capabilities()`.
- **`lua/plugins/treesitter.lua`** — parsers for every language the LSP
  list covers (go, hcl, python, bash, yaml, dockerfile, helm, lua,
  markdown, cpp), highlighting + indent both enabled.
- **`lua/plugins/telescope.lua`** — `<leader>ff` find files, `<leader>fg`
  live grep, `<leader>fb` buffers.
- **`lua/plugins/git.lua`** (`gitsigns.nvim`) — stock config, no overrides.
- **`lua/plugins/statusline.lua`** (`lualine.nvim`) — themed from the same
  `dms` base46 theme as the colorscheme (`lualine.themes._base46("dms")`);
  falls back to lualine's own `"auto"` theme if that lookup fails (e.g.
  `dms.lua` hasn't been generated yet).
- **`lua/plugins/base46.lua`** (`AvengeMedia/base46`) — same engine
  NvChad uses; loaded here standalone (no NvChad) purely to render the
  desktop's dynamic colorscheme. `matugenTemplateNeovim` must be on in DMS
  settings (`.config/dank-shell`'s `scripts/40-config.sh`) for it to have
  anything to render — base46 watches `~/.config/nvim/colors/dms.lua` and
  live-reloads on change, same file `matugen`/DMS write to on every
  wallpaper/theme switch.
- **`lua/config/theme.lua`** — applies the `dms` colorscheme, falling back
  to the built-in `habamax` if `dms` isn't defined yet (fresh install,
  before the first matugen run, or `matugenTemplateNeovim` still off).

Colors update automatically in the running editor whenever the desktop
theme changes — no `:colorscheme` re-run needed, no separate sync step to
maintain here.

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
