#!/bin/bash

#sudo -v  # cache credentials once if needed
#echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER-temp > /dev/null
#trap 'sudo rm -f /etc/sudoers.d/$USER-temp 2>/dev/null' EXIT  # auto-clean when script ends

# Ask if they want to backup their .config
read -p "Do you want to backup your current .config directory? (y/n, default: y): " backup_choice
backup_choice=${backup_choice:-y}  # Default to 'y' if empty
if [[ "$backup_choice" == "y" ]]; then
    cp -r ~/.config ~/.config_backup
    echo "Backup of .config created at ~/.config_backup"
fi

yay -S --needed brave-bin companion input-remapper vscodium-bin wlogout wttrbar xone-dkms xone-dongle-firmware blueman bluez bluez-utils btrfs-assistant btrfs-progs discord file-roller font-manager ghostty grub-btrfs gtk3 gtk4 helvum htop hypridle hyprland hyprlock hyprpolkitagent hyprshot kvantum kvantum-qt5 libpulse matugen nemo nwg-look openrgb pavucontrol qt5-wayland qt5ct qt6-multimedia-ffmpeg qt6-virtualkeyboard qt6-wayland qt6ct rofi samba sddm sddm-kcm smartmontools snapper starship steam swaync swww ttf-jetbrains-mono-nerd unzip vim vlc vlc-plugin-ffmpeg waybar yad zram-generator

#    systemctl enable bluetooth
#    systemctl --user enable pipewire.service
#    systemctl --user enable pipewire-pulse.service
#    systemctl --user start pipewire.service
#    systemctl --user start pipewire-pulse.service
    # Copy files
    sudo cp -a ~/archlinux_hyprland/.config/* ~/.config/
    sudo cp -a ~/archlinux_hyprland/.local/* ~/.local/
    sudo cp -a ~/archlinux_hyprland/etc/* /etc/
    sudo cp -a ~/archlinux_hyprland/usr/* /usr/
    sudo cp -a ~/archlinux_hyprland/.bashrc ~/.bashrc

# Ask if they want to use hyprexpo
read -p "Do you want use hyprexpo? (y/n, default: y): " hyprexpo_choice
hyprexpo_choice=${hyprexpo_choice:-y}  # Default to 'y' if empty
if [[ "$hyprexpo_choice" == "y" ]]; then
sudo pacman -S --needed meson cpio cmake
hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm enable hyprexpo
else
    # Disable the keybind when hyprexpo is not installed
    sed -i '/bind = SUPER, TAB, hyprexpo:expo, toggle/s/^/#/' ~/.config/hypr/modules/binds.conf
fi

# Wallpaper select
echo "Opening wallpaper selector..."
python3 ~/.config/matugen/scripts/wallpaper-select.py

notify-send "Good job $USER, You did it! Open Terminal with MOD+T."
