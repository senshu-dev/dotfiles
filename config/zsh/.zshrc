export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="theunraveler"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

export EDITOR=nvim

# Zoxide: z for fuzzy jump, zi for interactive
eval "$(zoxide init zsh)"

# FZF key bindings and completions
source <(fzf --zsh)

# Aliases
alias hrl='hyprctl reload'
alias up='paru -Syu'
