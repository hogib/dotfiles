#Utils
alias ls='eza --icons --group-directories-first'
alias ll='eza -al --icons --group-directories-first'
alias tree='eza --tree --icons'
alias l='ls'
alias la='ll'

alias cat='bat'
alias rm='rm -i'
alias cp='advcp -i -g'
alias mv='advmv -i -g'
alias lg='lazygit'

alias rc='nvim ~/.zshrc'
alias src='source ~/.zshrc'
alias arc='nvim ~/dotfiles/zsh/configs/aliases.zsh'
alias clr='clear'
alias dots='cd ~/dotfiles && git pull && cd'
alias gpf='git push origin main --force-with-lease'

# Suffix aliases
alias -s py='python'
alias -s md='bat'
alias -s toml='nvim'
alias -s conf='nvim'
alias -s txt='nvim'

#Nordvpn Quick
alias germ='nordvpn connect Germany'
alias usa='nordvpn connect United_States'
alias uk='nordvpn connect United_Kingdom'
alias vpn='nordvpn connect'
alias dsc='nordvpn disconnect'
alias killsw='nordvpn set killswitch on'
alias nkillsw='nordvpn set killswitch off'

#compiler and build system aliases 
alias cc='clang'
alias c='clang'
alias c++='clang++'
alias cx='clang++'

