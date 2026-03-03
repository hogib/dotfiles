Dotfile Preset Switcher

A Python-based system for hot-swapping Hyprland configurations, Waybar layouts, and system themes using symlink injection.
1. Core Logic

Instead of sourcing hardcoded files, hyprland.conf sources a symlinked directory (UserConfigs). This script changes where that symlink points, effectively swapping the entire configuration context (Keybinds, Animations, Rules) instantly.
2. Dependencies

Ensure these are installed on the new machine before running the script:

    Python 3 (Standard library only)

    Rofi (or compatible fork like rofi-wayland)

    SWWW (Wallpaper daemon)

    Wallust (Color generation)

3. Directory Structure

The system relies on a specific folder hierarchy.
Plaintext

~/.config/hypr/
├── hyprland.conf            # Sources ./UserConfigs/*
├── scripts/
│   └── UniverseSwitcher.py  # The logic script
├── UserConfigs/             # SYMLINK -> Pointing to active preset
└── presets/                 # Storage for all themes
    ├── Default/
    │   ├── UserKeybinds.conf
    │   ├── UserAnimations.conf
    │   ├── wallpaper.png    # Used for swww & wallust
    │   ├── waybar_config    # SYMLINK -> ~/.config/waybar/configs/[Layout File]
    │   └── waybar_style.css # SYMLINK -> ~/.config/waybar/style/[Style File]
    └── Gaming/
        └── ... (Same structure)

4. Installation & Migration

Run these commands to convert a standard JaKooLit setup into this modular format:
Bash

# 1. Create the presets directory
mkdir -p ~/.config/hypr/presets

# 2. Move existing configs to be the 'Default' preset
mv ~/.config/hypr/UserConfigs ~/.config/hypr/presets/Default

# 3. Create the symlink (The "Portal")
ln -s ~/.config/hypr/presets/Default ~/.config/hypr/UserConfigs

# 4. Fix Waybar Links (CRITICAL)
# Inside each preset, waybar_config must be a link to a FILE, not a folder.
cd ~/.config/hypr/presets/Default
rm -rf waybar_config waybar_style.css
ln -s "$HOME/.config/waybar/configs/[TOP] Simple" waybar_config
ln -s "$HOME/.config/waybar/style/[Wallust Transparent] Crystal Clear.css" waybar_style.css

5. Usage
Triggering the Menu

Add this to ~/.config/hypr/presets/Default/UserKeybinds.conf (and all other presets):
Ini, TOML

# Use a key that conflicts with nothing. Avoid Super+Shift+U (defaults to Special Workspace)
bind = $mainMod SHIFT, E, exec, python3 ~/.config/hypr/scripts/UniverseSwitcher.py

Creating a New Preset

    cp -r ~/.config/hypr/presets/Default ~/.config/hypr/presets/NewTheme

    Replace wallpaper.png inside the new folder.

    Update the waybar_config and waybar_style.css symlinks inside the new folder to point to different Waybar layouts.

    (Optional) Edit UserAnimations.conf for theme-specific performance settings.

6. Extending (Python)

The script uses an OOP approach. To add support for new apps (e.g., Discord, Firefox):

    Open UniverseSwitcher.py.

    Create a class inheriting from UniverseModule.

    Implement the swap(self, preset_path) method.

    Add the class instance to the modules list in the main() function.

7. Troubleshooting

Issue: Waybar crashes or doesn't load after switch.

    Cause: The waybar_config inside the preset folder is likely a symlink to a directory, or it's a hard file copy.

    Fix: It must be a symlink to a specific file (e.g., configs/[TOP] Simple).

Issue: Colors are unreadable (low contrast).

    Cause: Wallust generated colors based on a low-contrast wallpaper.

    Fix: Edit UniverseSwitcher.py to use the hard backend: self.run_cmd(["wallust", "run", str(wall_file), "-b", "hard"])

Issue: Windows disappear when switching.

    Cause: You bound the script to Super+Shift+U, which triggers "Move to Special Workspace" in Hyprland.

    Fix: Change the keybind to Super+Shift+E or unbind the special workspace shortcut.