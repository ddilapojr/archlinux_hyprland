#!/bin/bash

read -p "Do you want to backup your current .config directory? (y/n, default: y): " backup_choice
backup_choice=${backup_choice:-y}
if [[ "$backup_choice" == "y" ]]; then
    cp -r ~/.config ~/.config_backup
    echo "Backup of .config created at ~/.config_backup"
fi

    #vscodium \

yay -S --needed --noconfirm \
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
    blueman \
    bluez \
    bluez-utils \
    ghostty \
    nemo \
    samba \
    yad \
    file-roller \
    unzip \

systemctl --user enable --now hyprpolkitagent matugen waybar swaync swww hypridle hyprlock

# Copy files
sudo cp -a $HOME/archlinux_hyprland/.config/* ~/.config/
sudo cp -a $HOME/archlinux_hyprland/.local/* ~/.local/
sudo cp -a $HOME/archlinux_hyprland/etc/* /etc/
sudo cp -a $HOME/archlinux_hyprland/usr/* /usr/
sudo cp -a $HOME/archlinux_hyprland/.bashrc ~/.bashrc

read -p "Do you want use hyprexpo? (y/n, default: y): " hyprexpo_choice
hyprexpo_choice=${hyprexpo_choice:-y}
if [[ "$hyprexpo_choice" == "y" ]]; then
    sudo pacman -S --needed --noconfirm cmake meson ninja pkg-config cpio gcc
    hyprpm update
    hyprpm add https://github.com/hyprwm/hyprland-plugins
    hyprpm enable hyprexpo
else
    sed -i '/bind = SUPER, TAB, hyprexpo:expo, toggle/s/^/#/' ~/.config/hypr/modules/binds.conf
fi

echo "Opening wallpaper selector..."
python3 ~/.config/matugen/scripts/wallpaper-select.py
notify-send "Good job $USER, You did it! Open Terminal with MOD+T."