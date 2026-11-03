# ~/.config/bash/functions.bash  -- port of ~/dotfiles/zsh/shell_scripts/functions.zsh
# Left out on the server: _shutdown (halts the machine), nordvpn and bluetooth helpers.

fetchrulette() { # run a random installed fetch
    local -a fetches=()
    local f
    for f in fastfetch bifetch transfetch archfetch ytufetch; do
        command -v "$f" >/dev/null && fetches+=("$f")
    done
    if ((${#fetches[@]} == 0)); then
        echo "fetchrulette: no fetch programs installed"
        return 1
    fi
    "${fetches[RANDOM % ${#fetches[@]}]}"
}

caffeine() { # inhibit idling
    if [ "$1" = "on" ]; then
        echo "Caffeine mode ON (Idling disabled)"
        systemd-inhibit --what=idle --who="User" --why="Manual Override" sleep infinity &
        echo $! >/tmp/caffeine.pid
    elif [ "$1" = "off" ]; then
        if [ -f /tmp/caffeine.pid ]; then
            kill "$(cat /tmp/caffeine.pid)"
            rm -f /tmp/caffeine.pid
            echo "Caffeine mode OFF"
        else
            echo "Caffeine was not running."
        fi
    else
        echo "Usage: caffeine [on|off]"
    fi
}

silent() { # pipe all output to /dev/null and disown
    "$@" &>/dev/null &
    disown
}

glall() {
    find . -name ".git" -prune -execdir sh -c '
        if [ -n "$(git remote)" ]; then
            echo "Pulling $(pwd)..."
            git pull
        fi
    ' \;
}

extract() {
    if [[ ! -f "$1" ]]; then
        echo "'$1' is not a valid file"
        return 1
    fi
    case "$1" in
    *.tar.bz2 | *.tbz2) tar xjf "$1" ;;
    *.tar.gz | *.tgz) tar xzf "$1" ;;
    *.tar.xz | *.txz) tar xJf "$1" ;;
    *.tar.zst) tar --zstd -xf "$1" ;;
    *.tar) tar xf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.gz) gunzip "$1" ;;
    *.zip) unzip "$1" ;;
    *.7z) 7z x "$1" ;;
    *.zst) unzstd "$1" ;;
    *) echo "'$1' cannot be extracted via extract()" ;;
    esac
}

copy() { # copy to the LOCAL clipboard through the terminal (OSC 52); works over ssh and tmux
    local data
    if (($# > 0)); then
        data=$(base64 -w0 <"$1")
    else
        data=$(base64 -w0)
    fi
    if [ -n "$TMUX" ]; then
        printf '\033Ptmux;\033\033]52;c;%s\a\033\\' "$data"
    else
        printf '\033]52;c;%s\a' "$data"
    fi
}

bak() {
    command cp -a -- "$1" "${1}.$(date +%Y%m%d-%H%M).bak"
}

groot() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null) && cd "$root" || echo "Not in a git repo"
}

cdf() {
    local file
    file=$(fzf +m -q "$1") && cd "$(dirname "$file")"
}

mkcd() {
    mkdir -p -- "$1" && cd -P -- "$1"
}
