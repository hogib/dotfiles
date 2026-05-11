layla(){
STATE_FILE="/tmp/layla_state"

LYRICS=(
    "You've got me on my knees."
    "I'm begging, darling please."
    "Darling won't you ease my worried mind."
)

local CURRENT_INDEX=1
if [ -f "$STATE_FILE" ]; then
    CURRENT_INDEX=$(cat "$STATE_FILE")
fi

echo "${LYRICS[$CURRENT_INDEX]}"

local NEXT_INDEX=$(( (CURRENT_INDEX % ${#LYRICS[@]}) + 1 ))

echo "$NEXT_INDEX" > "$STATE_FILE"
}
