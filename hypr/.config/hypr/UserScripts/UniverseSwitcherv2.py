#!/usr/bin/env python3
"""
Universe Switcher - A modular theme/preset switcher for Hyprland-based setups.
Swaps configurations for Hyprland, Waybar, wallpapers, Kitty, and SDDM.
"""

import logging
import shutil
import subprocess
import time
from abc import ABC, abstractmethod
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

# --- LOGGING SETUP ---
logging.basicConfig(
    level=logging.INFO,
    format="%(levelname)s: %(message)s"
)
logger = logging.getLogger(__name__)


# --- CONFIGURATION ---
@dataclass(frozen=True)
class Config:
    """Centralized configuration for all paths and settings."""
    home: Path = Path.home()
    
    @property
    def presets_dir(self) -> Path:
        return self.home / ".config/hypr/presets"
    
    @property
    def rofi_config(self) -> Path:
        return self.home / ".config/rofi/config-waybar-layout.rasi"
    
    @property
    def scripts_dir(self) -> Path:
        return self.home / ".config/hypr/scripts"
    
    @property
    def hyprland_user_configs(self) -> Path:
        return self.home / ".config/hypr/UserConfigs"
    
    @property
    def waybar_config(self) -> Path:
        return self.home / ".config/waybar/config"
    
    @property
    def waybar_style(self) -> Path:
        return self.home / ".config/waybar/style.css"
    
    @property
    def waybar_colors(self) -> Path:
        return self.home / ".config/waybar/wallust/colors-waybar.css"
    
    @property
    def wallust_colors_cache(self) -> Path:
        return self.home / ".cache/wallust/colors-waybar.css"
    
    @property
    def kitty_theme(self) -> Path:
        return self.home / ".config/kitty/current_theme.conf"
    
    @property
    def sddm_theme_dir(self) -> Path:
        return Path("/usr/share/sddm/themes/simple_sddm_2")


# --- UTILITIES ---
def run_command(
    cmd: list[str],
    check: bool = False,
    capture: bool = False
) -> Optional[subprocess.CompletedProcess]:
    """
    Execute a shell command with proper error handling.
    
    Args:
        cmd: Command and arguments as a list.
        check: Raise exception on non-zero exit code.
        capture: Capture and return stdout.
    
    Returns:
        CompletedProcess if capture=True, None otherwise.
    """
    try:
        kwargs = {
            "stdout": subprocess.PIPE if capture else subprocess.DEVNULL,
            "stderr": subprocess.DEVNULL,
            "check": check,
        }
        return subprocess.run(cmd, **kwargs)
    except subprocess.CalledProcessError as e:
        logger.error(f"Command failed: {' '.join(cmd)} (exit code {e.returncode})")
        return None
    except FileNotFoundError:
        logger.error(f"Command not found: {cmd[0]}")
        return None


def force_symlink(source: Path, target: Path) -> bool:
    """
    Atomically create or replace a symlink.
    
    Args:
        source: The file/directory the symlink points to.
        target: The symlink location.
    
    Returns:
        True if successful, False otherwise.
    """
    if not source.exists():
        logger.warning(f"Source does not exist: {source}")
        return False
    
    try:
        target.unlink(missing_ok=True)
        target.symlink_to(source)
        logger.info(f"Linked: {target.name} -> {source}")
        return True
    except OSError as e:
        logger.error(f"Failed to create symlink {target}: {e}")
        return False


def find_wallpaper(preset_path: Path) -> Optional[Path]:
    """Find the first wallpaper image in a preset directory."""
    for pattern in ("wallpaper.*", "*.png", "*.jpg", "*.jpeg"):
        if match := next(preset_path.glob(pattern), None):
            return match
    return None


def send_signal(process_name: str, signal: str) -> bool:
    """Send a signal to a process by name."""
    return run_command(["pkill", signal, process_name]) is not None


# --- BASE MODULE ---
class Module(ABC):
    """Abstract base class for switchable components."""
    
    def __init__(self, config: Config):
        self.config = config
    
    @property
    @abstractmethod
    def name(self) -> str:
        """Human-readable module name for logging."""
        pass
    
    @abstractmethod
    def swap(self, preset_path: Path) -> bool:
        """
        Apply the preset configuration.
        
        Args:
            preset_path: Path to the preset directory.
        
        Returns:
            True if successful, False otherwise.
        """
        pass


# --- MODULE IMPLEMENTATIONS ---
class HyprlandModule(Module):
    """Swaps Hyprland user configuration directory."""
    
    @property
    def name(self) -> str:
        return "Hyprland"
    
    def swap(self, preset_path: Path) -> bool:
        return force_symlink(preset_path, self.config.hyprland_user_configs)


class WaybarModule(Module):
    """Swaps Waybar config and style files."""
    
    @property
    def name(self) -> str:
        return "Waybar"
    
    def swap(self, preset_path: Path) -> bool:
        config_ok = force_symlink(
            preset_path / "waybar_config",
            self.config.waybar_config
        )
        style_ok = force_symlink(
            preset_path / "waybar_style.css",
            self.config.waybar_style
        )
        return config_ok and style_ok


class WallpaperModule(Module):
    """Sets wallpaper using swww daemon."""
    
    @property
    def name(self) -> str:
        return "Wallpaper"
    
    def swap(self, preset_path: Path) -> bool:
        wall_file = find_wallpaper(preset_path)
        if not wall_file:
            logger.warning(f"No wallpaper found in {preset_path}")
            return False
        
        self._ensure_swww_daemon()
        self._set_wallpaper(wall_file)
        return True
    
    def _ensure_swww_daemon(self) -> None:
        """Start swww daemon if not already running."""
        result = subprocess.run(
            ["pgrep", "-x", "swww-daemon"],
            stdout=subprocess.DEVNULL
        )
        if result.returncode != 0:
            subprocess.Popen(["swww-daemon", "--format", "xrgb"])
            time.sleep(0.5)
            logger.info("Started swww-daemon")
    
    def _set_wallpaper(self, wall_file: Path) -> None:
        """Apply wallpaper with transition effect."""
        subprocess.Popen([
            "swww", "img", str(wall_file),
            "--transition-type", "grow",
            "--transition-pos", "0.5,0.5",
            "--transition-step", "90"
        ])
        logger.info(f"Set wallpaper: {wall_file.name}")


class WallustModule(Module):
    """Generates color schemes from wallpaper using wallust."""
    
    @property
    def name(self) -> str:
        return "Wallust"
    
    def swap(self, preset_path: Path) -> bool:
        if not shutil.which("wallust"):
            logger.warning("wallust not found, skipping color generation")
            return False
        
        wall_file = find_wallpaper(preset_path)
        if not wall_file:
            return False
        
        # Generate colors
        run_command(["wallust", "run", str(wall_file), "-q"])
        
        # Copy to Waybar
        if self.config.wallust_colors_cache.exists():
            shutil.copy(
                self.config.wallust_colors_cache,
                self.config.waybar_colors
            )
            send_signal("waybar", "-SIGUSR2")
            logger.info("Applied wallust colors to Waybar")
        
        # Reload Kitty to override any wallust changes
        send_signal("kitty", "-SIGUSR1")
        return True


class KittyModule(Module):
    """Swaps Kitty terminal theme."""
    
    @property
    def name(self) -> str:
        return "Kitty"
    
    def swap(self, preset_path: Path) -> bool:
        source = preset_path / "kitty_theme.conf"
        if not source.exists():
            logger.debug(f"No Kitty theme in preset: {preset_path.name}")
            return True  # Not an error, just no theme provided
        
        success = force_symlink(source, self.config.kitty_theme)
        if success:
            send_signal("kitty", "-SIGUSR1")
        return success


class SddmModule(Module):
    """Updates SDDM login screen wallpaper (requires sudo)."""
    
    @property
    def name(self) -> str:
        return "SDDM"
    
    def swap(self, preset_path: Path) -> bool:
        wall_file = find_wallpaper(preset_path)
        if not wall_file:
            return False
        
        if not self.config.sddm_theme_dir.exists():
            logger.warning(f"SDDM theme not found: {self.config.sddm_theme_dir}")
            return False
        
        bg_dest = self.config.sddm_theme_dir / "Backgrounds" / "current_wall.jpg"
        theme_conf = self.config.sddm_theme_dir / "theme.conf"
        
        # Build commands safely (no shell injection)
        commands = [
            ["sudo", "mkdir", "-p", str(bg_dest.parent)],
            ["sudo", "cp", str(wall_file), str(bg_dest)],
            ["sudo", "sed", "-i",
             's|^Background=.*|Background="Backgrounds/current_wall.jpg"|',
             str(theme_conf)],
        ]
        
        # Create a script to run in terminal
        script = " && ".join(" ".join(cmd) for cmd in commands)
        
        subprocess.Popen([
            "kitty",
            "--class", "sddm_updater",
            "--title", "SDDM Password Required",
            "--hold",
            "-e", "sh", "-c", script
        ])
        
        logger.info("Launched SDDM updater (requires password)")
        return True


# --- USER INTERFACE ---
class RofiSelector:
    """Handles preset selection via Rofi."""
    
    def __init__(self, config: Config):
        self.config = config
    
    def get_current_preset(self) -> str:
        """Detect the currently active preset."""
        link = self.config.hyprland_user_configs
        if link.is_symlink():
            return link.resolve().name
        return "Unknown"
    
    def list_presets(self) -> list[str]:
        """Get sorted list of available presets."""
        return sorted(
            d.name for d in self.config.presets_dir.iterdir() if d.is_dir()
        )
    
    def select(self) -> Optional[str]:
        """Display Rofi menu and return selected preset name."""
        current = self.get_current_preset()
        presets = self.list_presets()
        
        if not presets:
            logger.error(f"No presets found in {self.config.presets_dir}")
            return None
        
        # Build menu with current indicator
        menu_lines = []
        selected_idx = 0
        for i, name in enumerate(presets):
            if name == current:
                menu_lines.append(f"👉 {name}")
                selected_idx = i
            else:
                menu_lines.append(name)
        
        menu_str = "\n".join(menu_lines)
        
        result = subprocess.run(
            [
                "rofi", "-dmenu", "-i",
                "-p", "Select Universe",
                "-config", str(self.config.rofi_config),
                "-selected-row", str(selected_idx),
                "-mesg", f"Current: {current}"
            ],
            input=menu_str.encode(),
            stdout=subprocess.PIPE
        )
        
        choice = result.stdout.decode().strip()
        return choice.replace("👉 ", "") if choice else None


# --- MAIN APPLICATION ---
class UniverseSwitcher:
    """Main application orchestrating the theme switch."""
    
    def __init__(self, config: Optional[Config] = None):
        self.config = config or Config()
        self.selector = RofiSelector(self.config)
        self.modules: list[Module] = [
            HyprlandModule(self.config),
            WaybarModule(self.config),
            WallpaperModule(self.config),
            WallustModule(self.config),
            KittyModule(self.config),
            SddmModule(self.config),
        ]
    
    def run(self) -> bool:
        """Execute the universe switch workflow."""
        # 1. Get user selection
        choice = self.selector.select()
        if not choice:
            logger.info("No selection made, exiting")
            return False
        
        preset_path = self.config.presets_dir / choice
        if not preset_path.exists():
            logger.error(f"Preset not found: {preset_path}")
            return False
        
        logger.info(f"Switching to: {choice}")
        
        # 2. Apply all modules
        results = {}
        for module in self.modules:
            try:
                results[module.name] = module.swap(preset_path)
            except Exception as e:
                logger.error(f"{module.name} failed: {e}")
                results[module.name] = False
        
        # 3. Final refresh
        self._refresh()
        
        # 4. Report results
        failed = [name for name, ok in results.items() if not ok]
        if failed:
            logger.warning(f"Some modules had issues: {', '.join(failed)}")
        
        self._notify(choice, failed)
        return len(failed) == 0
    
    def _refresh(self) -> None:
        """Reload Hyprland and run refresh script."""
        run_command(["hyprctl", "reload"])
        refresh_script = self.config.scripts_dir / "Refresh.sh"
        if refresh_script.exists():
            subprocess.Popen([str(refresh_script)])
    
    def _notify(self, preset: str, failed: list[str]) -> None:
        """Send desktop notification with results."""
        if failed:
            message = f"Loaded: {preset}\nWarnings: {', '.join(failed)}"
        else:
            message = f"Loaded: {preset}"
        run_command(["notify-send", "Universe Switched", message])


def main() -> None:
    """Entry point."""
    switcher = UniverseSwitcher()
    switcher.run()


if __name__ == "__main__":
    main()