#!/usr/bin/env python3
import os
import subprocess
import shutil
import time
from pathlib import Path
from abc import ABC, abstractmethod

# --- GLOBAL CONFIG ---
HOME = Path.home()
PRESETS_DIR = HOME / ".config/hypr/presets"
ROFI_CONFIG = HOME / ".config/rofi/config-waybar-layout.rasi"
SCRIPTS_DIR = HOME / ".config/hypr/scripts"

# --- BASE CLASS ---
class UniverseModule(ABC):
    """Abstract base class for any switchable component."""
    
    @abstractmethod
    def swap(self, preset_path: Path):
        """Logic to apply the theme from the preset folder."""
        pass

    def force_symlink(self, source: Path, target: Path):
        """Helper: Atomically replaces a symlink."""
        if not source.exists():
            return # Skip if preset doesn't have this module
            
        if target.exists() or target.is_symlink():
            target.unlink()
        target.symlink_to(source)
        print(f"Linked {source.name} -> {target}")

    def run_cmd(self, cmd):
        """Helper: Runs a shell command silently."""
        subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

# --- MODULE IMPLEMENTATIONS ---

class HyprlandModule(UniverseModule):
    def __init__(self):
        self.target = HOME / ".config/hypr/UserConfigs"

    def swap(self, preset_path: Path):
        # This is the main folder link
        if preset_path.exists():
            if self.target.exists() or self.target.is_symlink():
                self.target.unlink()
            self.target.symlink_to(preset_path)

class WaybarModule(UniverseModule):
    def __init__(self):
        self.config_target = HOME / ".config/waybar/config"
        self.style_target = HOME / ".config/waybar/style.css"

    def swap(self, preset_path: Path):
        # 1. Swap Config
        self.force_symlink(preset_path / "waybar_config", self.config_target)
        
        # 2. Swap Style
        self.force_symlink(preset_path / "waybar_style.css", self.style_target)

class WallpaperModule(UniverseModule):
    def swap(self, preset_path: Path):
        # Find first image file
        wall_file = next(preset_path.glob("wallpaper.*"), None)
        
        if wall_file:
            # A. Ensure Daemon is alive
            if subprocess.call(["pgrep", "-x", "swww-daemon"]) != 0:
                subprocess.Popen(["swww-daemon", "--format", "xrgb"])
                time.sleep(0.5)

            # B. Set Wallpaper
            subprocess.Popen([
                "swww", "img", str(wall_file), 
                "--transition-type", "grow", 
                "--transition-pos", "0.5,0.5", 
                "--transition-step", "90"
            ])

            # C. Wallust (Colors)
            if shutil.which("wallust"):
                # 1. Run wallust (generates the cache)
                # We use -q (quiet) to stop it from printing escape codes to the current terminal
                self.run_cmd(["wallust", "run", str(wall_file), "-q"])
                
                # 2. Copy generated colors to Waybar (The part we actually want)
                src = HOME / ".cache/wallust/colors-waybar.css"
                dst = HOME / ".config/waybar/wallust/colors-waybar.css"
                if src.exists():
                    shutil.copy(src, dst)
                    # Update Waybar only
                    self.run_cmd(["pkill", "-SIGUSR2", "waybar"])
                
                # 3. THE SAFETY NET: Force Kitty Reload
                # This makes Kitty re-read kitty.conf immediately, overriding whatever wallust tried to do.
                self.run_cmd(["pkill", "-SIGUSR1", "kitty"])
# Not working, fix please              
class KittyModule(UniverseModule):
    def __init__(self):
        self.target = HOME / ".config/kitty/current_theme.conf"

    def swap(self, preset_path: Path):
        # Looks for 'kitty_theme.conf' in the preset folder
        source = preset_path / "kitty_theme.conf"
        
        if source.exists():
            self.force_symlink(source, self.target)
            # Reload Kitty to apply changes instantly
            self.run_cmd(["pkill", "-SIGUSR1", "kitty"])
class SddmModule(UniverseModule):
    def swap(self, preset_path: Path):
        # 1. Find the wallpaper
        wall_file = next(preset_path.glob("wallpaper.*"), None)
        
        # 2. Define SDDM Paths (Standard JaKooLit locations)
        # Verify this path exists on your system! 
        sddm_theme_dir = Path("/usr/share/sddm/themes/simple_sddm_2")
        bg_dest = sddm_theme_dir / "Backgrounds" / "current_wall.jpg"
        
        if wall_file and sddm_theme_dir.exists():
            print(f"Setting SDDM wallpaper to {wall_file.name}...")
            
            # 3. Construct the "Nuclear" Command
            # We chain commands: 
            # 1. mkdir (just in case)
            # 2. cp (copy the file and rename it to a fixed name 'current_wall.jpg')
            # 3. sed (edit theme.conf to point to this fixed name)
            
            cmd = (
                f"sudo mkdir -p '{bg_dest.parent}' && "
                f"sudo cp '{wall_file}' '{bg_dest}' && "
                f"sudo sed -i 's|^Background=.*|Background=\"Backgrounds/current_wall.jpg\"|' '{sddm_theme_dir}/theme.conf'"
            )
            
            # 4. Run it in a terminal so you can type your password
            subprocess.Popen([
                "kitty",
                "--class", "sddm_updater",
                "--title", "SDDM Password Required",
                "--hold",  # Keep open so you can see if it worked
                "-e", "sh", "-c", cmd
            ])
def get_user_selection():
    """Runs Rofi and returns the selected preset name."""
    # Detect current preset based on Hyprland link
    link = HOME / ".config/hypr/UserConfigs"
    current = link.resolve().name if link.exists() else "Unknown"

    # List folders
    options = sorted([d.name for d in PRESETS_DIR.iterdir() if d.is_dir()])
    
    # Build Menu String
    menu_str = ""
    selected_idx = 0
    for i, name in enumerate(options):
        if name == current:
            menu_str += f"👉 {name}\n"
            selected_idx = i
        else:
            menu_str += f"{name}\n"

    # Run Rofi
    cmd = [
        "rofi", "-dmenu", "-i", 
        "-p", "Select Universe", 
        "-config", str(ROFI_CONFIG),
        "-selected-row", str(selected_idx),
        "-mesg", f"Current: {current}"
    ]
    
    result = subprocess.run(
        cmd, 
        input=menu_str.encode(), 
        stdout=subprocess.PIPE
    )
    
    choice = result.stdout.decode().strip()
    return choice.replace("👉 ", "") if choice else None

def main():
    # 1. Get Selection
    choice = get_user_selection()
    if not choice:
        return

    print(f"Switching to: {choice}")
    preset_path = PRESETS_DIR / choice

    # 2. REGISTER YOUR MODULES HERE
    modules = [
        HyprlandModule(),
        WaybarModule(),
        WallpaperModule(),
        #KittyModule(), # <-- Just added this one line!
        SddmModule()
    ]

    # 3. Execute Swaps
    for module in modules:
        try:
            module.swap(preset_path)
        except Exception as e:
            print(f"Error in {module.__class__.__name__}: {e}")

    # 4. Final Refresh
    subprocess.run(["hyprctl", "reload"])
    subprocess.Popen([str(SCRIPTS_DIR / "Refresh.sh")])
    subprocess.run(["notify-send", "Universe Switched", f"Loaded: {choice}"])

if __name__ == "__main__":
    main()