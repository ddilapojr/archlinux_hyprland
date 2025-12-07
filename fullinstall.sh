#!/bin/bash

read -p "Do you want to backup your current .config directory? (y/n, default: y): " backup_choice
backup_choice=${backup_choice:-y}
if [[ "$backup_choice" == "y" ]]; then
    cp -r ~/.config ~/.config_backup
    echo "Backup of .config created at ~/.config_backup"
fi

yay -S --needed --noconfirm\
    hyprland \
    hypridle \
    hyprlock \
    hyprshot \
    hyprpolkitagent \
    matugen \
    waybar \
    swww \
    rofi \
    sddm \
    sddm-kcm \
    wlogout \
    starship \
    swaync \
    ttf-jetbrains-mono-nerd \
    gtk3 \
    gtk4 \
    nwg-look \
    qt5-wayland \
    qt5ct \
    qt6-multimedia-ffmpeg \
    qt6-virtualkeyboard \
    qt6-wayland \
    qt6ct \
    kvantum \
    kvantum-qt5 \
    wttrbar \
    pavucontrol \
    helvum \
    ghostty \
    nemo \
    samba \
    yad \
    file-roller \
    unzip \

# Copy files
sudo cp -a $HOME/archlinux_hyprland/.config/* ~/.config/
sudo cp -a $HOME/archlinux_hyprland/.local/* ~/.local/
sudo cp -a $HOME/archlinux_hyprland/etc/* /etc/
sudo cp -a $HOME/archlinux_hyprland/usr/* /usr/
sudo cp -a $HOME/archlinux_hyprland/.bashrc ~/.bashrc

systemctl --user enable --now hyprpolkitagent swww waybar swaync swww hypridle hyprlock

# Restart all services in current session (detached from terminal)
pkill hyprpolkitagent
pkill swww-daemon
pkill waybar
pkill dunst
pkill swaync
pkill hypridle
pkill hyprlock

hyprpolkitagent > /dev/null 2>&1 & disown
swww-daemon > /dev/null 2>&1 & disown
waybar > /dev/null 2>&1 & disown
swaync > /dev/null 2>&1 & disown
hypridle > /dev/null 2>&1 & disown
hyprlock > /dev/null 2>&1 & disown

sleep 1

read -p "Do you want to install your other cool shit? (y/n, default: y): " extra_choice
extra_choice=${extra_choice:-y}
if [[ "$extra_choice" == "y" ]]; then
yay -S --needed --noconfirm\
    brave-bin \
    companion \
    input-remapper \
    vscode \
    openrgb \
    steam \
    xone-dkms \
    xone-dongle-firmware \
    discord \
    snapper \
    btrfs-assistant \
    btrfs-progs \
    grub-btrfs \
    font-manager \
    htop \
    smartmontools \
    vim \
    vlc \
    vlc-plugin-ffmpeg \
    blueman \
    bluez \
    bluez-utils \
    pipewire \
    pipewire-alsa \
    pipewire-jack \
    pipewire-pulse \
    libpulse \    
fi

if [[ "$extra_choice" == "y" ]]; then
    systemctl enable --now bluetooth
    systemctl --user enable --now pipewire.service pipewire-pulse.service
fi

read -p "Do you want use hyprexpo? (y/n, default: y): " hyprexpo_choice
hyprexpo_choice=${hyprexpo_choice:-y}
if [[ "$hyprexpo_choice" == "y" ]]; then
    sudo pacman -S --needed --noconfirm --overwrite meson cpio cmake
    hyprpm update
    hyprpm add https://github.com/hyprwm/hyprland-plugins
    hyprpm enable hyprexpo
else
    sed -i '/bind = SUPER, TAB, hyprexpo:expo, toggle/s/^/#/' ~/.config/hypr/modules/binds.conf
fi

echo "Opening wallpaper selector..."
python3 ~/.config/matugen/scripts/wallpaper-select.py
notify-send "Good job $USER, You did it! Open Terminal with MOD+T."

read -p "Do you want to reboot now? (y/n, default: n): " reboot_choice
reboot_choice=${reboot_choice:-n}
if [[ "$reboot_choice" == "y" ]]; then
    echo "Rebooting..."
    systemctl reboot now
fi
