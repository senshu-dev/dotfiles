# Neovim config (`.config/nvim/`)

## Keybindings

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

## Commands

| Command | What it does |
|---|---|
| `:ArduinoInit <sketch-name>` | Prompts for a board FQBN, installs the core if missing, creates the sketch, generates `compile_commands.json` for clangd, opens the `.ino` |
| `:ArduinoRegen` | Regenerates `compile_commands.json` for the sketch in the cwd (run after adding `#include`s) |
| `:SshfsMount` | Same as `<leader>rm` |
| `:Lazy` | Plugin manager UI — install/update/clean/profile |
| `:checkhealth` | Diagnose LSP/treesitter/clipboard/etc. setup issues |
| `:LspInfo` | Show which LSP servers are attached to the current buffer |

## Things that need no action from you

- Colorscheme and statusline re-theme automatically whenever the desktop
  wallpaper/theme changes — no `:colorscheme` re-run, no restart.
- Undo history persists across restarts (`undofile`); system clipboard is
  the default register (`"+`/`"*` not needed for normal yank/paste).
- Indent is 4-space by default, 2-space for `yaml`/`json`/`javascript*`/
  `typescript*` filetypes — matches `.config/vscode.code-profile`.

## If something's not working

- LSP servers are installed via pacman/AUR (`scripts/20-packages.sh`), never
  `:Mason` — there is no Mason here. A missing server means installing its
  system package, not running an in-editor installer.
- `helm_ls` specifically needs the `--mflags --nocheck` AUR build path (its
  own integration tests fail sandboxed) — already handled by
  `scripts/20-packages.sh`, just noting it in case a manual AUR build of it
  ever fails.

## Architecture

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
