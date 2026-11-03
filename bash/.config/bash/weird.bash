layla() {
    local STATE_FILE="/tmp/layla_state"
    local LYRICS=(
        "You've got me on my knees."
        "I'm begging, darling please."
        "Darling won't you ease my worried mind."
    )
    local CURRENT_INDEX=0
    [ -f "$STATE_FILE" ] && CURRENT_INDEX=$(cat "$STATE_FILE")
    echo "${LYRICS[$CURRENT_INDEX]}"
    echo $(( (CURRENT_INDEX + 1) % ${#LYRICS[@]} )) >"$STATE_FILE"
}
