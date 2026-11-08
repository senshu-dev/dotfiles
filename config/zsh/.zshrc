export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="theunraveler"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

export EDITOR=nvim

# Zoxide: cd = smart jump, cdi = interactive
eval "$(zoxide init --cmd cd zsh)"

# FZF key bindings and completions
source <(fzf --zsh)

# Aliases
alias hrl='hyprctl reload'
alias up='paru -Syu'
