#
# ~/.bashrc  -- bash port of ~/dotfiles/zsh/.zshrc (oguz)
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#  PATHS & HISTORY
export MANPATH="$HOME/.local/share/man:$MANPATH"
export PATH="$HOME/.local/bin:/usr/local/bin:/opt/cuda/bin:$HOME/.cargo/bin:$PATH"
export HISTFILE=~/.bash_history
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend            # setopt appendhistory
shopt -s autocd                # setopt auto_cd
shopt -s cdspell dirspell globstar checkwinsize
export EDITOR='nvim'
export VISUAL='nvim'
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"   # uv

#  COMPLETION (bash-completion + case-insensitive, like matcher-list 'm:{a-z}={A-Z}')
[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'set colored-stats on'
bind 'set menu-complete-display-prefix on'

#  LINE EDITOR: vi mode (zsh-vi-mode) + history substring search on arrows
set -o vi
for km in vi-insert vi-command emacs; do
    bind -m $km '"\e[A": history-search-backward'
    bind -m $km '"\e[B": history-search-forward'
    bind -m $km '"\eOA": history-search-backward'
    bind -m $km '"\eOB": history-search-forward'
done
bind -m vi-insert '"\C-l": clear-screen'
bind -m vi-insert '"\C-a": beginning-of-line'
bind -m vi-insert '"\C-e": end-of-line'
# sudo plugin: Esc Esc (in command mode, i.e. press Esc twice from insert) prefixes the line with sudo
bind -m vi-command '"\e": "0isudo \e"'

#  TOOLS INITIALIZATION
command -v fzf    >/dev/null && eval "$(fzf --bash)"                   # Ctrl-R / Ctrl-T / Alt-C
command -v zoxide >/dev/null && eval "$(zoxide init bash --cmd cd)"
command -v direnv >/dev/null && eval "$(direnv hook bash)"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"   # fzf-tab preview
export FZF_ALT_C_OPTS="--preview 'eza -1 --color=always {}'"

#  colored-man-pages
export LESS_TERMCAP_mb=$'\e[1;31m' LESS_TERMCAP_md=$'\e[1;36m' LESS_TERMCAP_me=$'\e[0m' \
       LESS_TERMCAP_se=$'\e[0m' LESS_TERMCAP_so=$'\e[1;44;33m' LESS_TERMCAP_ue=$'\e[0m' LESS_TERMCAP_us=$'\e[1;32m'
export GROFF_NO_SGR=1

#  ble.sh (autosuggestions + syntax highlighting), only if installed
[ -r ~/.local/share/blesh/ble.sh ] && source ~/.local/share/blesh/ble.sh --attach=none

for f in ~/.config/bash/aliases.bash ~/.config/bash/functions.bash ~/.config/bash/weird.bash; do
    [ -f "$f" ] && . "$f"
done

#  PROMPT: starship stands in for powerlevel10k
command -v starship >/dev/null && eval "$(starship init bash)" || PS1='[\u@\h \W]\$ '

[ -n "${BLE_VERSION-}" ] && ble-attach
