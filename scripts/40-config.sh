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

# Deploys the dank-shell submodule's QML tree as the live shell at
# ~/.config/quickshell (+ sibling ~/.config/dank-qml-common, required by
# quickshell/DankCommon's relative symlink). Skipped if a DMS deploy is
# already live (DMSShell.qml present) -- DMS persists live settings
# (theme, layout, ...) directly into files under that tree (e.g.
# Common/SettingsData.qml), so blindly re-copying on every `setup.sh config`
# rerun would silently wipe them. Anything else already at
# ~/.config/quickshell (an old shell, or nothing) gets backed up first, same
# convention as every manual dank-shell deploy before this was automated.
deploy_dank_shell() {
    local config_dir="$1" backup_dir

    if [[ -f "$HOME/.config/quickshell/DMSShell.qml" ]]; then
        info "dank-shell already deployed at ~/.config/quickshell, skipping (redeploy is a deliberate manual step -- see docs/dank-shell.md)"
        return 0
    fi

    if [[ -e "$HOME/.config/quickshell" ]]; then
        backup_dir="$HOME/.config/quickshell-backup-pre-dms-deploy-$(date +%Y%m%d-%H%M%S)"
        mv "$HOME/.config/quickshell" "$backup_dir"
        info "Backed up existing ~/.config/quickshell to $backup_dir"
    fi

    info "Deploying dank-shell as the live shell"
    cp -r "$config_dir/dank-shell/quickshell" "$HOME/.config/quickshell"
    rm -rf "$HOME/.config/dank-qml-common"
    cp -r "$config_dir/dank-shell/dank-qml-common" "$HOME/.config/dank-qml-common"
    ok "dank-shell deployed to ~/.config/quickshell"
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

    local host host_config_dir
    host="$(detect_host)"
    host_config_dir="$scripts_dir/../hosts/$host/config"
    if [[ -d "$host_config_dir" ]]; then
        info "Overlaying host config ($host)"
        cp -r "$host_config_dir/." "$HOME/.config/"
        ok "Host config overlaid"
    fi

    enable_nvim_matugen_template

    info "Building dms (dank-shell core)"
    make -C "$config_dir/dank-shell/core" build
    mkdir -p "$HOME/.local/bin"
    ln -sf "$config_dir/dank-shell/core/bin/dms" "$HOME/.local/bin/dms"
    ok "dms built and linked to ~/.local/bin/dms"

    deploy_dank_shell "$config_dir"
}
