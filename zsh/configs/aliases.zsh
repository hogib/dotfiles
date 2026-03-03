alias ls='eza --icons --group-directories-first'
alias ll='eza -al --icons --group-directories-first'
alias tree='eza --tree --icons'
alias l='ls'
alias la='ll'

alias cat='bat'
alias rm='rm -i'
alias cp='advcp -i -g'
alias mv='advmv -i -g'

alias rc='helix ~/.zshrc'
alias src='source ~/.zshrc'
alias cod='codium'
alias clr='clear'

#Fetches
alias ytufetch='fastfetch -c ~/.config/fastfetch/config-ytu-transparent.jsonc'
alias archfetch='fastfetch -c ~/.config/fastfetch/config-archbtw.jsonc'
alias transfetch="hyfetch -C=$HOME/.config/transfetch.json"
alias bifetch="hyfetch -C=$HOME/.config/hyfetchbi.json"

#Cheat
alias cheat='bat cheatsheet.md'

# Suffix aliases
alias -s py='python'
alias -s md='bat'
alias -s toml='helix'
alias -s conf='helix'
alias -s txt='helix'

#Nordvpn Quick
alias germ='nordvpn connect Germany' 
alias usa='nordvpn connect United_States'
alias uk='nordvpn connect United_Kingdom'
alias vpn='nordvpn connect'
alias disc='nordvpn disconnect'
alias killsw='nordvpn set killswitch on'
alias nkillsw='nordvpn set killswitch off'

#rclone mount google drive to ~/Drive
alias gdrive='rclone mount gdrive: ~/Drive'
alias hx='helix'
