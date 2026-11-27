# Powerlevel10k instant prompt. Keep at the top.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

plugins=(
    you-should-use
    git
    fzf-tab
    archlinux
    zsh-autosuggestions
    extract
    web-search
    colored-man-pages
    rust
    rsync
    cp
    sudo
    kitty
    zsh-history-substring-search
    zsh-vi-mode
    fast-syntax-highlighting
)

# Extra completions; must be on fpath before oh-my-zsh runs compinit.
fpath+=~/.zfunc

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
source $ZSH/oh-my-zsh.sh

#  LOCATIONS (derived, not hard-coded)
: ${XDG_CONFIG_HOME:=$HOME/.config}
ZSH_CONFIG_DIR="$XDG_CONFIG_HOME/zsh"
# Repo root: follow the stowed ~/.zshrc symlink back to <repo>/zsh/.zshrc
if [[ -z $DOTFILES ]]; then
    DOTFILES=${${(%):-%x}:A:h:h}
    [[ -d $DOTFILES/zsh ]] || DOTFILES=$HOME/dotfiles
fi
export DOTFILES

#  PATHS & HISTORY
export MANPATH="$HOME/.local/share/man:$MANPATH"
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
[[ -z $VCPKG_ROOT && -d $HOME/Codings/vcpkg ]] && export VCPKG_ROOT=$HOME/Codings/vcpkg
# (N-/) keeps only directories that exist; typeset -U drops duplicates.
# The gem glob picks up whatever ruby version is installed.
typeset -U path
path=(
    $HOME/.local/bin(N-/)
    /usr/local/bin(N-/)
    /opt/cuda/bin(N-/)
    $HOME/.cargo/bin(N-/)
    $HOME/.local/share/gem/ruby/*/bin(N-/)
    ${VCPKG_ROOT:+$VCPKG_ROOT}(N-/)
    $path
)
setopt appendhistory
export EDITOR='nvim'
export VISUAL='nvim'

#  TOOLS INITIALIZATION
source <(fzf --zsh)
eval "$(zoxide init zsh --cmd cd)"
eval "$(direnv hook zsh)"

# FZF-Tab Preview
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 {}'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# ZSH options
setopt auto_cd
autoload -U zmv
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

for _f in $ZSH_CONFIG_DIR/{functions,weird,aliases}.zsh(N); do
    source $_f
done
unset _f

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
