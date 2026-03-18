[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


plugins=(    
    poetry
    git
    fzf-tab
    archlinux
    zsh-autosuggestions
    extract
    rust
    sudo
    you-should-use
    zsh-shift-select
    kitty
    zsh-history-substring-search
    zsh-vi-mode
    zsh-syntax-highlighting
)

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
source $ZSH/oh-my-zsh.sh


# ==========================================
#  PATHS & HISTORY
# ==========================================
export MANPATH="/home/oguzb/.local/share/man:$MANPATH"
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
export PATH="$HOME/.local/bin:$HOME/dotfiles/shell_scripts:$PATH"
setopt appendhistory
export EDITOR='nvim'
export VISUAL='nvim'
export PATH=/opt/cuda/bin:$PATH
export PATH="$HOME/.cargo/bin:$PATH"

# ==========================================
#  TOOLS INITIALIZATION
# ==========================================
source <(fzf --zsh)
eval "$(zoxide init zsh --cmd cd)"
eval $(thefuck --alias)
eval "$(direnv hook zsh)"

# FZF-Tab Preview
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 {}'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

source ~/dotfiles/zsh/configs/aliases.zsh

if [[ -f ~/dotfiles/zsh/shell_scripts/functions.zsh ]]; then
    source ~/dotfiles/zsh/shell_scripts/functions.zsh
fi
