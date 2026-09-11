# 40-config.sh — copies the entire .config directory into ~/.config.
#
# The .config directory lives next to this script (../.config). It
# resolves its own path so it works no matter where setup.sh is invoked
# from.

# DMS's own matugen "neovim" template is disabled by default
# (matugenTemplateNeovim: false in SettingsSpec.js) - flip it on so
# ~/.config/nvim/colors/dms.lua gets generated. Idempotent: creates the
# settings file if DMS hasn't run yet, merges the key if it has, never
# touches any other setting.
enable_nvim_matugen_template() {
    local settings_file="$HOME/.config/DankMaterialShell/settings.json"
    mkdir -p "$(dirname "$settings_file")"
    [[ -f "$settings_file" ]] || echo '{}' >"$settings_file"
    local tmp
    tmp="$(mktemp)"
    jq '.matugenTemplateNeovim = true' "$settings_file" >"$tmp" && mv "$tmp" "$settings_file"
    ok "matugenTemplateNeovim enabled in DMS settings"
}

setup_config() {
    local scripts_dir config_dir
    scripts_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    config_dir="$scripts_dir/../.config"

    if [[ ! -d "$config_dir" ]]; then
        warn ".config not found at '$config_dir', skipping"
        return 0
    fi

    info "Initializing dank-shell submodule"
    git -C "$scripts_dir/.." submodule update --init --recursive
    ok "dank-shell submodule ready"

    info "Installing .config"
    mkdir -p "$HOME/.config"
    cp -r "$config_dir/." "$HOME/.config/"
    ok ".config installed"

    enable_nvim_matugen_template

    info "Building dms (dank-shell core)"
    make -C "$config_dir/dank-shell/core" build
    mkdir -p "$HOME/.local/bin"
    ln -sf "$config_dir/dank-shell/core/bin/dms" "$HOME/.local/bin/dms"
    ok "dms built and linked to ~/.local/bin/dms"
}
