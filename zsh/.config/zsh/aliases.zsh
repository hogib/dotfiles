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
alias arc='nvim "$ZSH_CONFIG_DIR/aliases.zsh"'
alias frc='nvim "$ZSH_CONFIG_DIR/functions.zsh"'
alias clr='clear'
alias dots='git -C "$DOTFILES" pull'
alias gpf='git push origin main --force-with-lease'

# Suffix aliases
alias -s py='python'
alias -s md='bat'
alias -s toml='nvim'
alias -s conf='nvim'
alias -s txt='nvim'
alias -s {cpp,hpp,c,h}=nvim

#Nordvpn Quick
alias germ='nordvpn connect Germany'
alias usa='nordvpn connect United_States'
alias uk='nordvpn connect United_Kingdom'
alias vpn='nordvpn connect'
alias dsc='nordvpn disconnect'
alias killsw='nordvpn set killswitch on'
alias nkillsw='nordvpn set killswitch off'
alias home='nordvpn set protocol nordlynx'
alias away='nordvpn set protocol openvpn_tcp'

#compiler and build system aliases
alias cc='clang'
alias c='clang'
alias c++='clang++'
alias cx='clang++'

# Global aliases
alias -g G="| grep -i"
alias -g C="| wl-copy"
alias -g L="| less"

alias nv='nvim .'

alias cn='connect'
alias ds='disconnect'
alias zat='silent zathura'
