#!/bin/bash

# Exit on any error
set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_msg() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root (don't use sudo)"
   exit 1
fi

# Check if yay is installed
if ! command -v yay &> /dev/null; then
    print_error "yay (AUR helper) is not installed. Please install it first:"
    echo "  git clone https://aur.archlinux.org/yay.git"
    echo "  cd yay"
    echo "  makepkg -si"
    exit 1
fi

# Ask about backing up .config
read -p "Do you want to backup your current .config directory? (y/n, default: y): " backup_choice
backup_choice=${backup_choice:-y}

if [[ "$backup_choice" == "y" ]]; then
    if [[ -d ~/.config ]]; then
        BACKUP_DIR=~/.config_backup_$(date +%Y%m%d_%H%M%S)
        cp -r ~/.config "$BACKUP_DIR"
        print_msg "Backup created at $BACKUP_DIR"
    else
        print_warning "~/.config doesn't exist, skipping backup"
    fi
fi

# Update system first
print_msg "Updating system..."
yay -Syu --noconfirm

# Install packages
print_msg "Installing packages..."
yay -S --needed --noconfirm \
    brave-bin \
    companion \
    input-remapper \
    vscodium-bin \
    wlogout \
    wttrbar \
    xone-dkms \
    xone-dongle-firmware \
    blueman \
    bluez \
    bluez-utils \
    btrfs-assistant \
    btrfs-progs \
    discord \
    file-roller \
    font-manager \
    ghostty \
    grub-btrfs \
    gtk3 \
    gtk4 \
    helvum \
    htop \
    hypridle \
    hyprland \
    hyprlock \
    hyprpolkitagent \
    hyprshot \
    kvantum \
    kvantum-qt5 \
    libpulse \
    matugen \
    nemo \
    nwg-look \
    openrgb \
    pavucontrol \
    qt5-wayland \
    qt5ct \
    qt6-multimedia-ffmpeg \
    qt6-virtualkeyboard \
    qt6-wayland \
    qt6ct \
    rofi \
    samba \
    sddm \
    sddm-kcm \
    smartmontools \
    snapper \
    starship \
    steam \
    swaync \
    swww \
    ttf-jetbrains-mono-nerd \
    unzip \
    vim \
    vlc \
    vlc-plugin-ffmpeg \
    waybar \
    yad \
    zram-generator

# Enable and start services
print_msg "Enabling services..."
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

# Enable pipewire for current user
systemctl --user enable pipewire.service pipewire-pulse.service
systemctl --user start pipewire.service pipewire-pulse.service

# Check if source directory exists
DOTFILES_DIR=~/archlinux_hyprland
if [[ ! -d "$DOTFILES_DIR" ]]; then
    print_error "Dotfiles directory not found at $DOTFILES_DIR"
    print_msg "Please clone your dotfiles repository first"
    exit 1
fi

# Copy configuration files
print_msg "Copying configuration files..."

# Create directories if they don't exist
mkdir -p ~/.config
mkdir -p ~/.local

# Copy .config files (remove existing if present)
if [[ -d "$DOTFILES_DIR/.config" ]]; then
    cp -rf "$DOTFILES_DIR/.config/"* ~/.config/
    print_msg "Copied .config files"
else
    print_warning "$DOTFILES_DIR/.config not found"
fi

# Copy .local files
if [[ -d "$DOTFILES_DIR/.local" ]]; then
    cp -rf "$DOTFILES_DIR/.local/"* ~/.local/
    print_msg "Copied .local files"
else
    print_warning "$DOTFILES_DIR/.local not found"
fi

# Copy system files (requires sudo)
if [[ -d "$DOTFILES_DIR/etc" ]]; then
    sudo cp -rf "$DOTFILES_DIR/etc/"* /etc/
    print_msg "Copied /etc files"
else
    print_warning "$DOTFILES_DIR/etc not found"
fi

if [[ -d "$DOTFILES_DIR/usr" ]]; then
    sudo cp -rf "$DOTFILES_DIR/usr/"* /usr/
    print_msg "Copied /usr files"
else
    print_warning "$DOTFILES_DIR/usr not found"
fi

# Copy .bashrc
if [[ -f "$DOTFILES_DIR/.bashrc" ]]; then
    cp "$DOTFILES_DIR/.bashrc" ~/.bashrc
    print_msg "Copied .bashrc"
else
    print_warning "$DOTFILES_DIR/.bashrc not found"
fi

# Ask about hyprexpo
read -p "Do you want to use hyprexpo? (y/n, default: y): " hyprexpo_choice
hyprexpo_choice=${hyprexpo_choice:-y}

if [[ "$hyprexpo_choice" == "y" ]]; then
    print_msg "Installing hyprexpo plugin..."
    
    # Install build dependencies
    sudo pacman -S --needed --noconfirm meson cpio cmake
    
    # Update and add hyprland plugins
    hyprpm update
    hyprpm add https://github.com/hyprwm/hyprland-plugins
    hyprpm enable hyprexpo
    
    print_msg "hyprexpo installed and enabled"
else
    # Disable the keybind when hyprexpo is not installed
    if [[ -f ~/.config/hypr/modules/binds.conf ]]; then
        sed -i '/bind = SUPER, TAB, hyprexpo:expo, toggle/s/^/#/' ~/.config/hypr/modules/binds.conf
        print_msg "Disabled hyprexpo keybind"
    fi
fi

# Wallpaper select
if [[ -f ~/.config/matugen/scripts/wallpaper-select.py ]]; then
    print_msg "Opening wallpaper selector..."
    python3 ~/.config/matugen/scripts/wallpaper-select.py
else
    print_warning "Wallpaper selector script not found"
fi

# Final message
print_msg "Installation complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Good job $USER, You did it!${NC}"
echo "Open Terminal with MOD+T"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "You may want to:"
echo "  - Reboot your system"
echo "  - Log out and log back in"
echo "  - Run 'systemctl --user restart pipewire' if audio doesn't work"
echo ""

# Send notification if possible
if command -v notify-send &> /dev/null; then
    notify-send "Installation Complete" "Good job $USER, You did it! Open Terminal with MOD+T."
fi