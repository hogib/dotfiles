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
export MANPATH="$HOME/.local/share/man:$MANPATH"
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
export PATH="$HOME/.local/bin:$HOME/dotfiles/shell_scripts:/usr/local/bin:/opt/cuda/bin:$HOME/.cargo/bin:$HOME/.local/share/gem/ruby/3.4.0/bin:$PATH"
setopt appendhistory
export EDITOR='nvim'
export VISUAL='nvim'

# ==========================================
#  TOOLS INITIALIZATION
# ==========================================
source <(fzf --zsh)
eval "$(zoxide init zsh --cmd cd)"
eval "$(thefuck --alias)"
eval "$(direnv hook zsh)"

# FZF-Tab Preview
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 {}'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

if [[ -f ~/Codings/Zsh/aliases.zsh ]]; then
    source ~/Codings/Zsh/aliases.zsh
fi


if [[ -f ~/dotfiles/zsh/shell_scripts/functions.zsh ]]; then
    source ~/dotfiles/zsh/shell_scripts/functions.zsh
fi

if [[ -f ~/dotfiles/zsh/configs/aliases.zsh ]]; then
    source ~/dotfiles/zsh/configs/aliases.zsh 
fi

if [[ -f ~/Codings/Zsh/functions.zsh ]]; then
    source ~/Codings/Zsh/functions.zsh 
fi
