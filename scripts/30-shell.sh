# 30-shell.sh — zsh and oh-my-zsh setup.

setup_shell() {
    info "Setting zsh as default shell"
    sudo chsh "$USER" -s /usr/bin/zsh

    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        warn "oh-my-zsh already installed, skipping"
    else
        info "Installing oh-my-zsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    if [[ -f "$HOME/.zshrc" ]]; then
        info "Setting zsh theme to 'theunraveler'"
        sed -i 's/ZSH_THEME=".*"/ZSH_THEME="theunraveler"/' "$HOME/.zshrc"

        if ! grep -q 'zoxide init zsh' "$HOME/.zshrc"; then
            info "Adding zoxide init to .zshrc"
            echo -e '\neval "$(zoxide init zsh)"' >> "$HOME/.zshrc"
        fi
    else
        warn ".zshrc not found, skipping theme"
    fi
    ok "zsh configured"
}
