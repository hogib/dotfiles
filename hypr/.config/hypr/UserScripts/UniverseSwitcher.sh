#!/usr/bin/env bash

# --- PATHS ---
PRESETS_DIR="$HOME/.config/hypr/presets"
LINK_TARGET="$HOME/.config/hypr/UserConfigs"

# Waybar targets
WB_CONFIG_TARGET="$HOME/.config/waybar/config"
WB_STYLE_TARGET="$HOME/.config/waybar/style.css"

# Rofi config
ROFI_CONFIG="$HOME/.config/rofi/config-waybar-layout.rasi"
SCRIPTSDIR="$HOME/.config/hypr/scripts"

# --- 1. MENU GENERATION ---
# Get current preset name (based on where UserConfigs points)
current_preset=$(readlink -f "$LINK_TARGET" | xargs basename)

# Find directories in presets folder
options=$(find "$PRESETS_DIR" -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | sort)

# Pre-select current with marker
row_index=0
i=0
display_options=""
while IFS= read -r line; do
    if [ "$line" == "$current_preset" ]; then
        display_options+="👉 $line\n"
        row_index=$i
    else
        display_options+="$line\n"
    fi
    ((i++))
done <<< "$options"

# Show Rofi
choice=$(echo -e "$display_options" | rofi -dmenu -i -p "Select Universe" \
    -config "$ROFI_CONFIG" \
    -selected-row "$row_index" \
    -mesg "Current: $current_preset")

# Exit if cancelled
if [ -z "$choice" ]; then exit 0; fi

# Clean selection
target_preset=$(echo "$choice" | sed 's/👉 //')
PRESET_PATH="$PRESETS_DIR/$target_preset"

# --- 2. THE SWAP LOGIC ---

# A. Swap UserConfigs (Hyprland Settings)
if [ -d "$PRESET_PATH" ]; then
    rm "$LINK_TARGET"
    ln -s "$PRESET_PATH" "$LINK_TARGET"
fi

# B. Swap Waybar Layout
if [ -e "$PRESET_PATH/waybar_config" ]; then
    ln -sf "$PRESET_PATH/waybar_config" "$WB_CONFIG_TARGET"
fi

# C. Swap Waybar Style
if [ -e "$PRESET_PATH/waybar_style.css" ]; then
    ln -sf "$PRESET_PATH/waybar_style.css" "$WB_STYLE_TARGET"
fi

# D. Swap Wallpaper & Colors
wall_file=$(find "$PRESET_PATH" -maxdepth 1 -type f \( -iname "wallpaper.*" \) | head -n 1)

if [ -n "$wall_file" ]; then
    # 1. Update Wallpaper (Force Swapping)
    # Using 'swww img' directly for speed
    if ! pgrep -x "swww-daemon" > /dev/null; then
        swww-daemon --format xrgb &
        sleep 0.5
    fi
    swww img "$wall_file" --transition-type grow --transition-pos 0.5,0.5 --transition-step 90 &
    
    # 2. Generate Colors (Synchronously wait for this!)
    if command -v wallust &> /dev/null; then
        # Generate the colors
        wallust run "$wall_file" > /dev/null 2>&1
        
        # Copy the generated colors to Waybar's folder
        cp -f "$HOME/.cache/wallust/colors-waybar.css" "$HOME/.config/waybar/wallust/colors-waybar.css"
        
        # HOT RELOAD WAYBAR CSS
        # This forces Waybar to re-read the CSS file immediately without a full restart
        pkill -SIGUSR2 waybar
        # --- THE FIX ---
        # Force Kitty to reload its config immediately. 
        # If your kitty.conf loads a specific static theme, this resets the colors.
        pkill -SIGUSR1 kitty4
    fi
fi

# --- 3. FULL REFRESH ---
# Reloads Hyprland config and restarts Waybar/SwayNC to catch layout changes
# We run this last to ensure everything is settled.
hyprctl reload
"${SCRIPTSDIR}/Refresh.sh" &

notify-send "Universe Switched" "Loaded: $target_preset"