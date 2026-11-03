# ~/.config/bash/aliases.bash  -- port of ~/dotfiles/zsh/configs/aliases.zsh

#Utils
alias ls='eza --icons --group-directories-first'
alias ll='eza -al --icons --group-directories-first'
alias tree='eza --tree --icons'
alias l='ls'
alias la='ll'

alias cat='bat'
alias rm='rm -i'
if command -v advcp >/dev/null; then
    alias cp='advcp -i -g'
    alias mv='advmv -i -g'
else
    alias cp='cp -i'
    alias mv='mv -i'
fi
alias lg='lazygit'

alias rc='nvim ~/.bashrc'
alias src='source ~/.bashrc'
alias arc='nvim ~/.config/bash/aliases.bash'
alias frc='nvim ~/.config/bash/functions.bash'
alias clr='clear'
alias gpf='git push origin main --force-with-lease'

# Suffix aliases (zsh `alias -s`) have no bash equivalent; `o FILE` opens by extension instead.
o() {
    case "$1" in
    *.py) python "$@" ;;
    *.md) bat "$@" ;;
    *.toml | *.conf | *.txt | *.cpp | *.hpp | *.c | *.h) nvim "$@" ;;
    *) xdg-open "$@" 2>/dev/null || nvim "$@" ;;
    esac
}

#compiler and build system aliases
if command -v clang >/dev/null; then
    alias cc='clang'
    alias c='clang'
    alias c++='clang++'
    alias cx='clang++'
fi

# Global aliases (zsh `alias -g G/C/L`) don't exist in bash; use the pipes directly:
#   ... | grep -i    ... | less    ... | copy   (copy() sends to the local clipboard over OSC 52)

alias nv='nvim .'

# archlinux plugin
alias pacupg='sudo pacman -Syu'
alias pacin='sudo pacman -S'
alias pacins='sudo pacman -U'
alias pacrem='sudo pacman -Rns'
alias pacss='pacman -Ss'
alias pacqi='pacman -Qi'
alias pacsi='pacman -Si'
alias pacorph='sudo pacman -Rns $(pacman -Qtdq)'
alias pacfiles='pacman -Ql'
alias pacown='pacman -Qo'
