#!/usr/bin/env bash
# dotfiles installer: installs package dependencies (apt / pacman / brew) and
# symlinks the selected Stow packages into $HOME.
#
#   ./install.sh                      # no args on a terminal -> TUI
#   ./install.sh --tui                # force the TUI
#   ./install.sh -p pacman zsh nvim   # install deps + stow zsh and nvim
#   ./install.sh -p brew --no-deps -a # stow everything, install nothing
#   ./install.sh -n -a                # dry run, print what would happen
#
# Written to run on macOS's stock bash 3.2: no associative arrays, no namerefs.
# Coreutils are called through `command` so user aliases never interfere.

set -o pipefail

DOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALL_PKGS="bash git hypr kitty niri nvim tmux zsh"
LINUX_ONLY="hypr niri"

PLATFORM=""     # apt | pacman | brew
DEPS=1          # 1 = install packages + plugin repos, 0 = stow only
DRY=0
YES=0
BACKUP=1        # move conflicting files aside instead of failing
TUI=0
SELECTED=""     # space separated stow packages

BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
OS="$(uname -s)"

# --------------------------------------------------------------------------
# output helpers
# --------------------------------------------------------------------------
if [ -t 1 ]; then
    C_RST=$'\033[0m' C_B=$'\033[1m' C_DIM=$'\033[2m'
    C_RED=$'\033[31m' C_GRN=$'\033[32m' C_YEL=$'\033[33m' C_BLU=$'\033[34m' C_CYN=$'\033[36m'
else
    C_RST='' C_B='' C_DIM='' C_RED='' C_GRN='' C_YEL='' C_BLU='' C_CYN=''
fi

info() { printf '%s::%s %s\n' "$C_BLU$C_B" "$C_RST" "$*"; }
ok()   { printf '%s ok%s %s\n' "$C_GRN" "$C_RST" "$*"; }
warn() { printf '%s !!%s %s\n' "$C_YEL" "$C_RST" "$*" >&2; }
die()  { printf '%serror:%s %s\n' "$C_RED$C_B" "$C_RST" "$*" >&2; exit 1; }

# run a command, or just print it in dry-run mode
run() {
    if [ "$DRY" = 1 ]; then
        printf '%s  $ %s%s\n' "$C_DIM" "$*" "$C_RST"
    else
        "$@"
    fi
}

has() { command -v "$1" >/dev/null 2>&1; }
in_list() { case " $2 " in *" $1 "*) return 0 ;; esac; return 1; }
add_unique() { # add_unique VAR word...
    local var=$1 w cur; shift
    for w in "$@"; do
        eval "cur=\$$var"
        in_list "$w" "$cur" || eval "$var=\"\${$var:+\$$var }\$w\""
    done
}

SUDO=""
[ "$(id -u)" -ne 0 ] && has sudo && SUDO="sudo"

usage() {
    command cat <<EOF
${C_B}usage:${C_RST} $(basename "$0") [options] [package...]

Installs dependencies and stows dotfile packages into \$HOME.
Packages: $ALL_PKGS

${C_B}options${C_RST}
  -p, --platform NAME   package manager: apt | pacman | brew (default: auto-detect)
  -d, --deps            install dependencies (default)
  -D, --no-deps         only symlink configs, install nothing (stow is still installed if missing)
  -a, --all             select every package available on this OS
  -t, --tui             interactive menu (default when run with no arguments on a terminal)
  -y, --yes             don't ask the package manager for confirmation
  -n, --dry-run         print what would be done without changing anything
      --no-backup       fail on conflicting files instead of moving them to ~/.dotfiles-backup
  -h, --help            show this help
EOF
}

# --------------------------------------------------------------------------
# dependency tables
# --------------------------------------------------------------------------
# generic dependency names per stow package
deps_for() {
    case $1 in
        bash) echo "bash bash-completion eza bat fzf zoxide direnv starship" ;;
        zsh)  echo "zsh eza bat fzf zoxide direnv lazygit fd ripgrep" ;;
        git)  echo "git" ;;
        kitty) echo "kitty" ;;
        nvim) echo "neovim git ripgrep fd unzip compiler make" ;;
        tmux) echo "tmux git" ;;
        hypr) echo "hypridle" ;;
        niri) echo "niri" ;;
    esac
}

# extra git-cloned deps per stow package (see install_extras)
extras_for() {
    case $1 in
        zsh)  echo "oh-my-zsh powerlevel10k zsh-plugins" ;;
        tmux) echo "tpm" ;;
    esac
}

# map a generic name to the manager's package name.
# prints nothing = not packaged there; "cask:x" = brew cask
map_pkg() {
    local mgr=$1 p=$2
    case "$mgr:$p" in
        apt:fd)              echo fd-find ;;
        apt:compiler)        echo build-essential ;;
        apt:make)            ;;                       # in build-essential
        pacman:compiler)     echo gcc ;;
        brew:compiler)       ;;                       # Xcode CLT provides clang
        brew:make)           ;;
        brew:kitty)          echo cask:kitty ;;
        brew:bash-completion) echo bash-completion@2 ;;
        brew:hypridle|brew:niri) ;;                   # Linux only
        *)                   echo "$p" ;;
    esac
}

pkg_available() {
    local mgr=$1 name=$2
    case $mgr in
        apt)    apt-cache show "$name" >/dev/null 2>&1 ;;
        pacman) pacman -Si "$name" >/dev/null 2>&1 || pacman -Sg "$name" >/dev/null 2>&1 ;;
        brew)
            case $name in
                cask:*) brew info --cask "${name#cask:}" >/dev/null 2>&1 ;;
                *)      brew info --formula "$name" >/dev/null 2>&1 ;;
            esac ;;
    esac
}

detect_platform() {
    if [ "$OS" = Darwin ]; then echo brew; return; fi
    if has pacman; then echo pacman
    elif has apt-get; then echo apt
    elif has brew; then echo brew
    fi
}

available_pkgs() { # stow packages that make sense on this OS
    local p out=""
    for p in $ALL_PKGS; do
        [ "$OS" != Linux ] && in_list "$p" "$LINUX_ONLY" && continue
        [ -d "$DOTDIR/$p" ] || continue
        out="$out${out:+ }$p"
    done
    echo "$out"
}

# --------------------------------------------------------------------------
# TUI (pure bash, draws to /dev/tty)
#   inputs:  M_LABELS[] M_DESCS[] M_SEL[] (0/1)
#   returns: 0 confirmed, 1 quit, 2 back; selection left in M_SEL[]
# --------------------------------------------------------------------------
tui_on()  { printf '\033[?1049h\033[?25l' >/dev/tty; stty -echo 2>/dev/null </dev/tty; }
tui_off() { printf '\033[?25h\033[?1049l' >/dev/tty; stty echo 2>/dev/null </dev/tty; }

tui_draw() {
    local mode=$1 title=$2 cur=$3 i mark line
    {
        printf '\033[H\033[2J'
        printf '\n  %s dotfiles installer %s\n\n' "$C_B$C_CYN" "$C_RST"
        printf '%s\n\n' "$title" | command sed 's/^/  /'
        for i in "${!M_LABELS[@]}"; do
            if [ "$mode" = radio ]; then
                [ "${M_SEL[$i]}" = 1 ] && mark="(*)" || mark="( )"
            else
                [ "${M_SEL[$i]}" = 1 ] && mark="[x]" || mark="[ ]"
            fi
            line=$(printf '%s %-10s %s%s%s' "$mark" "${M_LABELS[$i]}" "$C_DIM" "${M_DESCS[$i]}" "$C_RST")
            if [ "$i" = "$cur" ]; then
                printf '  %s>%s %s%s%s\n' "$C_CYN$C_B" "$C_RST" "$C_B" "$line" "$C_RST"
            else
                printf '    %s\n' "$line"
            fi
        done
        printf '\n  %s' "$C_DIM"
        if [ "$mode" = radio ]; then
            printf 'up/down or j/k move · enter select · left/h back · q quit'
        else
            printf 'up/down or j/k move · space toggle · a all/none · enter confirm · left/h back · q quit'
        fi
        printf '%s\n' "$C_RST"
    } >/dev/tty
}

tui_menu() {
    local mode=$1 title=$2 n=${#M_LABELS[@]} cur=0 key rest i any
    if [ "$mode" = radio ]; then
        for i in "${!M_SEL[@]}"; do [ "${M_SEL[$i]}" = 1 ] && cur=$i; done
    fi
    while :; do
        tui_draw "$mode" "$title" "$cur"
        IFS= read -rsn1 key </dev/tty || return 1
        if [ "$key" = $'\033' ]; then
            IFS= read -rsn2 -t 1 rest </dev/tty
            case $rest in
                '[A') key=k ;; '[B') key=j ;; '[D') key=h ;; '[C') key=l ;;
                *) key=h ;;  # bare Esc = back
            esac
        fi
        case $key in
            k) cur=$(( (cur - 1 + n) % n )) ;;
            j) cur=$(( (cur + 1) % n )) ;;
            h|$'\177'|$'\b') return 2 ;;
            q|Q) return 1 ;;
            ' '|l)
                if [ "$mode" = radio ]; then
                    for i in "${!M_SEL[@]}"; do M_SEL[$i]=0; done; M_SEL[$cur]=1
                else
                    [ "${M_SEL[$cur]}" = 1 ] && M_SEL[$cur]=0 || M_SEL[$cur]=1
                fi ;;
            a|A)
                [ "$mode" = radio ] && continue
                any=0; for i in "${!M_SEL[@]}"; do [ "${M_SEL[$i]}" = 0 ] && any=1; done
                for i in "${!M_SEL[@]}"; do M_SEL[$i]=$any; done ;;
            '')
                if [ "$mode" = radio ]; then
                    for i in "${!M_SEL[@]}"; do M_SEL[$i]=0; done; M_SEL[$cur]=1
                fi
                return 0 ;;
        esac
    done
}

pkg_desc() {
    case $1 in
        bash)  echo "bashrc, aliases, starship prompt" ;;
        git)   echo "global .gitconfig" ;;
        hypr)  echo "hypridle config" ;;
        kitty) echo "kitty terminal + theme" ;;
        niri)  echo "niri compositor (noctalia shell)" ;;
        nvim)  echo "neovim (lazy.nvim)" ;;
        tmux)  echo "tmux + TPM plugins" ;;
        zsh)   echo "zsh, oh-my-zsh, p10k, plugins" ;;
    esac
}

run_tui() {
    [ -r /dev/tty ] || die "--tui needs a terminal"
    tui_on
    trap 'tui_off' EXIT
    trap 'tui_off; exit 130' INT TERM

    local step=1 rc i p avail summary
    avail=$(available_pkgs)
    while :; do
        case $step in
        1)  M_LABELS=(apt pacman brew)
            M_DESCS=("Debian / Ubuntu" "Arch Linux" "Homebrew (macOS / Linux)")
            M_SEL=(0 0 0)
            for i in 0 1 2; do [ "${M_LABELS[$i]}" = "$PLATFORM" ] && M_SEL[$i]=1; done
            tui_menu radio "Which package manager should be used?"; rc=$?
            [ $rc = 1 ] && { tui_off; exit 0; }
            [ $rc = 2 ] && continue
            for i in 0 1 2; do [ "${M_SEL[$i]}" = 1 ] && PLATFORM=${M_LABELS[$i]}; done
            step=2 ;;
        2)  M_LABELS=() M_DESCS=() M_SEL=()
            for p in $avail; do
                M_LABELS+=("$p"); M_DESCS+=("$(pkg_desc "$p")")
                if [ -z "$SELECTED" ] || in_list "$p" "$SELECTED"; then M_SEL+=(1); else M_SEL+=(0); fi
            done
            tui_menu check "Which configs should be stowed into \$HOME?"; rc=$?
            [ $rc = 1 ] && { tui_off; exit 0; }
            [ $rc = 2 ] && { step=1; continue; }
            SELECTED=""
            for i in "${!M_LABELS[@]}"; do [ "${M_SEL[$i]}" = 1 ] && SELECTED="$SELECTED${SELECTED:+ }${M_LABELS[$i]}"; done
            step=3 ;;
        3)  M_LABELS=(deps backup yes dry-run)
            M_DESCS=("install packages + zsh/tmux plugins via $PLATFORM"
                     "move conflicting files to ~/.dotfiles-backup"
                     "don't prompt inside the package manager"
                     "only print what would happen")
            M_SEL=("$DEPS" "$BACKUP" "$YES" "$DRY")
            tui_menu check "Options"; rc=$?
            [ $rc = 1 ] && { tui_off; exit 0; }
            [ $rc = 2 ] && { step=2; continue; }
            DEPS=${M_SEL[0]} BACKUP=${M_SEL[1]} YES=${M_SEL[2]} DRY=${M_SEL[3]}
            step=4 ;;
        4)  summary=$(printf '%sReady to go%s\n\n  platform  %s\n  packages  %s\n  deps      %s\n  backup    %s\n  dry run   %s' \
                "$C_B" "$C_RST" "$PLATFORM" "${SELECTED:-(none)}" \
                "$( [ "$DEPS" = 1 ] && echo yes || echo no)" \
                "$( [ "$BACKUP" = 1 ] && echo yes || echo no)" \
                "$( [ "$DRY" = 1 ] && echo yes || echo no)")
            M_LABELS=(install back quit) M_DESCS=("" "change something" "") M_SEL=(1 0 0)
            tui_menu radio "$summary"; rc=$?
            [ $rc = 1 ] && { tui_off; exit 0; }
            [ $rc = 2 ] && { step=3; continue; }
            [ "${M_SEL[2]}" = 1 ] && { tui_off; exit 0; }
            [ "${M_SEL[1]}" = 1 ] && { step=3; continue; }
            break ;;
        esac
    done
    tui_off
    trap - EXIT INT TERM
}

# --------------------------------------------------------------------------
# installing
# --------------------------------------------------------------------------
pm_refresh() {
    case $PLATFORM in
        apt)  run $SUDO apt-get update ;;
        brew) run brew update ;;
        pacman) ;;  # no -Sy alone: partial upgrades break Arch
    esac
}

pm_install() { # pm_install name...
    [ $# -eq 0 ] && return 0
    local y=""
    case $PLATFORM in
        apt)    [ "$YES" = 1 ] && y="-y"; run $SUDO apt-get install $y "$@" ;;
        pacman) [ "$YES" = 1 ] && y="--noconfirm"; run $SUDO pacman -S --needed $y "$@" ;;
        brew)
            local formulae=() casks=() n
            for n in "$@"; do
                case $n in cask:*) casks+=("${n#cask:}") ;; *) formulae+=("$n") ;; esac
            done
            [ ${#formulae[@]} -gt 0 ] && run brew install "${formulae[@]}"
            [ ${#casks[@]} -gt 0 ] && run brew install --cask "${casks[@]}"
            ;;
    esac
}

install_deps() {
    local generic="git stow curl" p d name names="" missing=""
    for p in $SELECTED; do add_unique generic $(deps_for "$p"); done

    info "Resolving packages for $PLATFORM"
    pm_refresh
    for d in $generic; do
        name=$(map_pkg "$PLATFORM" "$d")
        [ -z "$name" ] && continue
        if [ "$DRY" = 1 ] || pkg_available "$PLATFORM" "$name"; then
            add_unique names "$name"
        else
            add_unique missing "$name"
        fi
    done
    [ -n "$missing" ] && warn "not available via $PLATFORM, skipping: $missing"
    info "Installing: $names"
    pm_install $names || warn "package manager reported errors, continuing"

    # Debian ships bat/fd under other binary names
    if [ "$PLATFORM" = apt ]; then
        run command mkdir -p "$HOME/.local/bin"
        has batcat && ! has bat && run command ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
        has fdfind && ! has fd  && run command ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    fi
}

git_clone() { # git_clone url dest
    if [ -d "$2/.git" ]; then
        ok "$(basename "$2") already present"
    else
        run command mkdir -p "$(dirname "$2")"
        run git clone --depth=1 -q "$1" "$2" && ok "cloned $(basename "$2")"
    fi
}

install_extras() {
    local p e extras="" omz="$HOME/.oh-my-zsh" custom
    for p in $SELECTED; do add_unique extras $(extras_for "$p"); done
    [ -z "$extras" ] && return 0
    has git || { warn "git missing, skipping plugin repos"; return 0; }
    info "Installing plugin repos"
    custom="${ZSH_CUSTOM:-$omz/custom}"
    for e in $extras; do
        case $e in
            # cloned directly: the official installer would overwrite .zshrc
            oh-my-zsh)     git_clone https://github.com/ohmyzsh/ohmyzsh.git "$omz" ;;
            powerlevel10k) git_clone https://github.com/romkatv/powerlevel10k.git "$custom/themes/powerlevel10k" ;;
            zsh-plugins)
                git_clone https://github.com/MichaelAquilina/zsh-you-should-use.git    "$custom/plugins/you-should-use"
                git_clone https://github.com/Aloxaf/fzf-tab.git                        "$custom/plugins/fzf-tab"
                git_clone https://github.com/zsh-users/zsh-autosuggestions.git         "$custom/plugins/zsh-autosuggestions"
                git_clone https://github.com/zsh-users/zsh-history-substring-search.git "$custom/plugins/zsh-history-substring-search"
                git_clone https://github.com/jeffreytse/zsh-vi-mode.git                "$custom/plugins/zsh-vi-mode"
                git_clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$custom/plugins/fast-syntax-highlighting"
                ;;
            tpm) git_clone https://github.com/tmux-plugins/tpm.git "$HOME/.config/tmux/plugins/tpm" ;;
        esac
    done
}

# targets (relative to $HOME) that block stowing a package
stow_conflicts() {
    stow -n -v -d "$DOTDIR" -t "$HOME" --restow "$1" 2>&1 | command sed -n \
        -e 's/.*over existing target \(.*\) since .*/\1/p' \
        -e 's/.*existing target is [^:]*: \(.*\)$/\1/p'
}

stow_pkgs() {
    local p f conflicts
    if ! has stow; then
        if [ "$DRY" = 1 ]; then warn "stow not installed (would be installed)"
        else
            info "stow is required, installing it"
            pm_install "$(map_pkg "$PLATFORM" stow)"
            has stow || die "could not install GNU stow"
        fi
    fi
    # keep stow from folding all of ~/.config into one package's symlink
    run command mkdir -p "$HOME/.config"

    info "Stowing into $HOME"
    for p in $SELECTED; do
        if has stow; then
            conflicts=$(stow_conflicts "$p")
            if [ -n "$conflicts" ]; then
                if [ "$BACKUP" = 1 ]; then
                    while IFS= read -r f; do
                        [ -z "$f" ] && continue
                        warn "$p: backing up ~/$f"
                        run command mkdir -p "$BACKUP_DIR/$(dirname "$f")"
                        run command mv "$HOME/$f" "$BACKUP_DIR/$f"
                    done <<EOF
$conflicts
EOF
                else
                    warn "$p: conflicts with existing files, skipping:"
                    printf '      ~/%s\n' $conflicts >&2
                    continue
                fi
            fi
        fi
        run stow -d "$DOTDIR" -t "$HOME" --restow "$p" && ok "stowed $p"
    done
}

# --------------------------------------------------------------------------
# main
# --------------------------------------------------------------------------
main() {
    local argc=$# p
    while [ $# -gt 0 ]; do
        case $1 in
            -p|--platform) PLATFORM=$2; shift ;;
            --platform=*)  PLATFORM=${1#*=} ;;
            -d|--deps)     DEPS=1 ;;
            -D|--no-deps)  DEPS=0 ;;
            -a|--all)      SELECTED=$(available_pkgs) ;;
            -t|--tui)      TUI=1 ;;
            -y|--yes)      YES=1 ;;
            -n|--dry-run)  DRY=1 ;;
            --no-backup)   BACKUP=0 ;;
            -h|--help)     usage; exit 0 ;;
            -*)            usage >&2; die "unknown option: $1" ;;
            *)             in_list "$1" "$ALL_PKGS" || die "unknown package: $1 (have: $ALL_PKGS)"
                           add_unique SELECTED "$1" ;;
        esac
        shift
    done

    [ -z "$PLATFORM" ] && PLATFORM=$(detect_platform)
    [ $argc -eq 0 ] && [ -t 0 ] && [ -t 1 ] && TUI=1
    [ "$TUI" = 1 ] && run_tui

    case $PLATFORM in
        apt|pacman|brew) ;;
        "") die "could not detect a package manager, pass -p apt|pacman|brew" ;;
        *)  die "unsupported platform: $PLATFORM (use apt, pacman or brew)" ;;
    esac
    [ -z "$SELECTED" ] && die "no packages selected (name some, use -a, or run with --tui)"
    for p in $SELECTED; do
        [ "$OS" != Linux ] && in_list "$p" "$LINUX_ONLY" && warn "$p is Linux-only, stowing anyway"
    done

    local need=$PLATFORM; [ "$need" = apt ] && need=apt-get
    if [ "$DRY" = 0 ] && ! has "$need"; then
        die "$need not found on this system"
    fi

    printf '\n%splatform%s %s  %spackages%s %s  %sdeps%s %s%s\n\n' \
        "$C_B" "$C_RST" "$PLATFORM" "$C_B" "$C_RST" "$SELECTED" "$C_B" "$C_RST" \
        "$( [ "$DEPS" = 1 ] && echo yes || echo no)" "$( [ "$DRY" = 1 ] && echo '  (dry run)')"

    if [ "$DEPS" = 1 ]; then
        install_deps
        install_extras
    fi
    stow_pkgs

    echo
    ok "done"
    [ -d "$BACKUP_DIR" ] && info "conflicting files were moved to $BACKUP_DIR"
    if in_list tmux "$SELECTED" && [ "$DEPS" = 1 ]; then
        info "tmux: press prefix + I (C-a I) to install plugins"
    fi
    if in_list zsh "$SELECTED" && [ "${SHELL##*/}" != zsh ]; then
        info "zsh: make it your login shell with: chsh -s \"\$(command -v zsh)\""
    fi
    if in_list bash "$SELECTED" && [ "$DEPS" = 1 ]; then
        info "bash: ble.sh and advcpmv are optional and not installed automatically"
    fi
}

main "$@"
