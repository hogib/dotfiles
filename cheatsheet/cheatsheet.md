# ARCH LINUX CHEAT SHEET
# ======================

# --- PACMAN (Official Repos) ---
sudo pacman -Syu        # UPDATE SYSTEM (Do this often! Never do partial upgrades)
sudo pacman -S <pkg>    # Install a package
sudo pacman -Rns <pkg>  # Remove package + unneeded dependencies + config files
pacman -Ss <query>      # Search for a package in repos
pacman -Qs <query>      # Search installed packages
pacman -Qi <pkg>        # Show detailed info about an installed package
pacman -Si <pkg>        # Show detailed info about a repo package

# --- YAY (AUR - Arch User Repository) ---
yay                     # Update System + AUR packages (just type 'yay')
yay -S <pkg>            # Install package from AUR (or Repos)
yay -Yc                 # Remove unneeded dependencies (Clean up)

# --- MAINTENANCE & CLEANING ---
sudo pacman -Sc         # Clear package cache (keep installed versions)
sudo pacman -Scc        # Nuke ALL cache (frees space, but redownload needed to reinstall)
pacman -Qdt             # List "Orphan" packages (installed as deps but no longer needed)
sudo pacman -Rns $(pacman -Qdtq) # Remove all orphans reclusively 
sudo paccache -r	# Run cleanup (keep 3 newest)
sudo journalctl --vacuum-time=2weeks # Remove logs, keep last 2 weeks
# --- SYSTEMD (Services) ---
sudo systemctl start <name>    # Start service now
sudo systemctl stop <name>     # Stop service now
sudo systemctl enable <name>   # Start service automatically on BOOT
sudo systemctl disable <name>  # Stop starting on BOOT
systemctl status <name>        # Check if running/error logs
systemctl list-units --type=service  # List all running services

# --- LOGS (Journalctl) ---
journalctl -xe          # Show end of logs (useful for debugging crashes)
journalctl -p 3 -xb     # Show errors (priority 3) from current boot (-b)
journalctl -f           # Follow logs in real-time

# --- ARCHIVES (Tar) ---
tar -xvf <file.tar.gz>  # Extract
tar -cvf <file.tar> <dir> # Compress

# --- NETWORKING (NetworkManager) ---
nmcli dev wifi list             # List available Wi-Fi networks
nmcli dev wifi connect <SSID> password <PASS>  # Connect to Wi-Fi
nmcli radio wifi off/on         # Turn Wi-Fi off/on
ip a                            # Show IP address (look for inet under wlan0/eth0)
ping -c 3 archlinux.org         # Check internet connection (pings 3 times)

# --- HYPRLAND (Common Keybindings) ---
# Note: Check ~/.config/hypr/hyprland.conf to customize these!
SUPER + Q           # Open Terminal (usually Kitty/Alacritty)
SUPER + C           # Kill (Close) active window
SUPER + M           # Exit Hyprland (Log out)
SUPER + E           # Open File Manager
SUPER + V           # Toggle window Floating/Tiling
SUPER + F           # Toggle Fullscreen
SUPER + R           # Open App Launcher (Wofi/Rofi)
SUPER + P           # Pseudo-tiling (keeps aspect ratio)
SUPER + J           # Toggles split

# --- AUDIO & BLUETOOTH ---
pactl set-sink-volume @DEFAULT_SINK@ +5%  # Volume Up
pactl set-sink-volume @DEFAULT_SINK@ -5%  # Volume Down
pactl set-source-mute @DEFAULT_SOURCE@ toggle # Mute Mic
bluetoothctl power on           # Turn on Bluetooth controller
bluetoothctl scan on            # Start scanning for devices
bluetoothctl connect <MAC_ADDR> # Connect to a device

# --- Zsh Aliases ---
rc # edit config
src # reload config quickly
fuck # fucks
mvd # Creates new directory and moves files there. Syntax mvd file.txt /path.
exhypr # hyprshutdown for logout 
editcheat # edit cheatsheet with nano
ytufetch # fastfetch with ytu logo

# --- ENDEAVOUR OS ESSENTIALS ---
yay                      # Update EVERYTHING (System + AUR). Run this daily.
eos-update --yay         # "Fix it" update. Use if standard 'yay' fails with GPG/Keyring errors.
eos-rankmirrors          # Sort download mirrors by speed (run if updates feel slow).
eos-pacdiff              # Merge config file changes (.pacnew files). Opens a "Diff" GUI.
akm                      # Arch Kernel Manager. Use to install 'linux-lts' (Long Term Support) kernel.
yay -Yc			 # Remove orphans
# --- NVIDIA & DRIVERS (EOS Specific) ---
nvidia-inst --check      # Check which Nvidia driver your card needs.
nvidia-inst              # auto-install proprietary Nvidia drivers + 32bit libs.
nvidia-inst -n           # Switch to open-source (nouveau) drivers (Emergency fix if screen is black).

# --- BOOTLOADER (Systemd-boot) ---
# Note: EOS uses systemd-boot, NOT Grub (usually).
bootctl status           # Check bootloader status.
bootctl list             # List available boot entries (kernels).
