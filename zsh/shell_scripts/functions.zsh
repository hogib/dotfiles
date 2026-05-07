# ~/dotfiles/zsh/shell_scripts/functions.zsh

shutdwn() {
    # --- CONFIG ---
    local COUNTDOWN_SEC=${1:-10}
    
    # --- COLORS ---
    local BR=$'\e[1;31m'  # BOLD Red
    local DR=$'\e[0;31m'  # DIM Red
    local W=$'\e[1;37m'   # White
    local N=$'\e[0m'      # Reset

    
    trap "echo -e '\n\n${W}[!] ADMINISTRATOR CREDENTIALS AUTHENTICATED. SEQUENCE ABORTED.${N}'; return" SIGINT

    #warning
    clear
    echo -e "\a"
    echo "${BR}[CRITICAL] KERNEL PANIC DETECTED AT MEMORY ADDRESS 0x000000${N}"
    echo "${BR}[CRITICAL] UNAUTHORIZED USER SESSION ACTIVE.${N}"
    echo ""
    echo "${W}INITIATING EMERGENCY CONTAINMENT PROTOCOL...${N}"
    sleep 1

    #pretend deleting a bunch of shit
    echo "${DR}--- BEGINNING RAPID DISK SANITIZATION ---${N}"
    
    local -a dirs=("/usr/bin" "/etc/shadow" "/home/oguzb/projects" "/var/log" "/sys/kernel" "/boot/efi")
    
    for i in {1..80}; do
        local rand_hex=$(printf "%08x" $((RANDOM * RANDOM)))
        local rand_dir=${dirs[$((RANDOM % ${#dirs[@]} + 1))]}
        echo "${DR}[system] purging inode 0x${rand_hex} from ${rand_dir}... ${BR}DELETED${N}"
        sleep 0.02
    done
    #dmesg | tail -n 50 | pv -qL 60

    # ask for bs password 
    echo ""
    echo "${BR}[!] PRIMARY DATA VOLUMES UNMOUNTED.${N}"
    echo "${W}ADMINISTRATIVE OVERRIDE REQUIRED TO CANCEL FINAL WIPE.${N}"
    
    echo -n "${W}ENTER PASSKEY > ${N}"
    read -rs input_pass

    echo ""
    echo "${DR}Decrypting hash signature...${N}"
    sleep 1.5

    # reveal that it is indeed a bs password and you can't get it right shithead
    echo "${BR}ERROR: INVALID CREDENTIALS. ATTEMPT LOGGED.${N}"
    sleep 0.5
    echo "${BR}LOCKOUT ENGAGED. GOODBYE.${N}"
    echo ""

    # countdown from whatever to give me enough time to keyboard interrupt if I need pc to be on
    local i=$COUNTDOWN_SEC
    while (( i > 0 )); do
        local hex=$(printf "%X" $((RANDOM * 32768)))
        printf "${BR}>> ZERO-FILLING SECTOR 0x${hex} [TIME: %02d] ${DR}(SIGINT TO ABORT)${N} \r" "$i"
        sleep 1
        ((i--))
    done

    echo ""
    echo "${W}SYSTEM HALT.${N}"
    
    trap - SIGINT
    shutdown -h now
}
fetchrulette() { # doesn't really work atm
    fetches=(
        "fastfetch"
        "bifetch"
        "transfetch"
        "archfetch"
        "ytufetch"

    )
    size=${#fetches[@]}
    index=$((RANDOM % size))
    selected_fetch="${fetches[$index]}"
    eval "$selected_fetch"
}
caffeine(){ # inhibit idling 
    if [ "$1" = "on" ]; then
        echo "Caffeine mode ON (Idling disabled)"
        systemd-inhibit --what=idle --who="User" --why="Manual Override" sleep infinity &
        echo $! > /tmp/caffeine.pid
    elif [ "$1" = "off" ]; then
        if [ -f /tmp/caffeine.pid ]; then
            kill $(cat /tmp/caffeine.pid)
            rm -f /tmp/caffeine.pid
            echo "Caffeine mode OFF"
        else
            echo "Caffeine was not running."
        fi
    else
        echo "Usage: caffeine [on|off]"
    fi

}

silent() { # pipe all output to dev/null and disown
  "$@" &> /dev/null &!
}
