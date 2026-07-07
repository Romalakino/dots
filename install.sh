#!/bin/bash
# Void Linux + Sway WM — Automated Setup
# HP Laptop 15s-eq1xxx (AMD Athlon Silver 3050U)
# 
# Usage: ./install.sh
# Requires: root access (password: set during installation)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err() { echo -e "${RED}[-]${NC} $1"; exit 1; }

[ "$(id -u)" -eq 0 ] && err "Don't run as root. Script will ask for sudo."

# ============================================
# 1. SYSTEM UPDATE
# ============================================
log "Updating system..."
sudo xbps-install -Syu -y

# ============================================
# 2. REPOSITORIES
# ============================================
log "Enabling repos (multilib, nonfree)..."
sudo xbps-install -y void-repo-multilib void-repo-nonfree
sudo xbps-install -Syu -y

# ============================================
# 3. CORE PACKAGES
# ============================================
log "Installing core packages..."
sudo xbps-install -y \
    base-system sudo bash dash \
    xbps curl wget git \
    neovim vim nvi \
    tmux

# ============================================
# 4. HARDWARE
# ============================================
log "Installing hardware support..."
sudo xbps-install -y \
    linux-firmware-amd linux-firmware-intel linux-firmware-broadcom \
    linux-firmware-network linux-firmware-nvidia \
    linux6.18 mesa mesa-dri mesa-vulkan-radeon mesa-vaapi \
    acpid chrony dbus elogind \
    iw wpa_supplicant ethtool pciutils usbutils \
    brightnessctl alsa-utils alsa-lib pavucontrol

# ============================================
# 5. SWAY + WAYLAND
# ============================================
log "Installing Sway + Wayland..."
sudo xbps-install -y \
    sway swaybg swayidle swaylock \
    wl-clipboard grim slurp mako wofi foot \
    waybar xdg-desktop-portal xdg-desktop-portal-wlr \
    xorg-server-xwayland

# ============================================
# 6. APPS
# ============================================
log "Installing apps..."
sudo xbps-install -y \
    firefox telegram-desktop \
    nautilus eza bat fzf fd ripgrep \
    fastfetch btop \
    xclip clipman

# ============================================
# 7. DEV TOOLS
# ============================================
log "Installing dev tools..."
sudo xbps-install -y \
    git nodejs python3 python3-pip \
    docker docker-cli docker-buildx

# ============================================
# 8. ICONS + FONTS
# ============================================
log "Installing icons and fonts..."
sudo xbps-install -y \
    papirus-icon-theme adwaita-icon-theme \
    dejavu-fonts-ttf ttf-opensans \
    nerd-fonts-ttf nerd-fonts-symbols-ttf \
    font-awesome6

# ============================================
# 9. KEYMAP (ru+en dual)
# ============================================
log "Installing dual RU/EN keymap..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/keymaps/ru-en.map" ]; then
    sudo cp "$SCRIPT_DIR/keymaps/ru-en.map" /usr/share/kbd/keymaps/i386/qwerty/
    log "Keymap installed: /usr/share/kbd/keymaps/i386/qwerty/ru-en.map"
fi

# ============================================
# 10. SING-BOX 1.10.2 (VPN)
# ============================================
log "Installing sing-box 1.10.2..."
SINGBOX_VERSION="1.10.2"
if ! command -v sing-box &>/dev/null || ! sing-box version 2>/dev/null | grep -q "$SINGBOX_VERSION"; then
    cd /tmp
    wget -q "https://github.com/SagerNet/sing-box/releases/download/v${SINGBOX_VERSION}/sing-box-${SINGBOX_VERSION}-linux-amd64.tar.gz"
    tar xzf "sing-box-${SINGBOX_VERSION}-linux-amd64.tar.gz"
    sudo cp "sing-box-${SINGBOX_VERSION}-linux-amd64/sing-box" /usr/local/bin/
    sudo chmod +x /usr/local/bin/sing-box
    rm -rf "sing-box-${SINGBOX_VERSION}"*
    log "sing-box $SINGBOX_VERSION installed"
else
    log "sing-box $SINGBOX_VERSION already installed"
fi

# ============================================
# 11. BIBATA CURSOR
# ============================================
log "Installing Bibata-Modern-Ice cursor..."
CURSOR_DIR="$HOME/.local/share/icons/Bibata-Modern-Ice"
if [ ! -d "$CURSOR_DIR" ]; then
    mkdir -p "$CURSOR_DIR"
    wget -q -O /tmp/bibata.zip "https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Modern-Ice.zip"
    unzip -q /tmp/bibata.zip -d /tmp/bibata
    cp -r /tmp/bibata/Bibata-Modern-Ice/* "$CURSOR_DIR/"
    rm -rf /tmp/bibata.zip /tmp/bibata
    log "Bibata cursor installed"
else
    log "Bibata cursor already installed"
fi

# ============================================
# 12. WALLPAPER
# ============================================
log "Setting up wallpaper..."
WALLPAPER_DIR="$HOME/.local/share/wallpapers"
mkdir -p "$WALLPAPER_DIR"
if [ -f "$SCRIPT_DIR/wallpapers/mt-fuji-bw.jpg" ]; then
    cp "$SCRIPT_DIR/wallpapers/mt-fuji-bw.jpg" "$WALLPAPER_DIR/"
fi

# ============================================
# 13. DOTFILES
# ============================================
log "Installing dotfiles..."
CONFIG_DIR="$HOME/.config"

# Backup existing configs
for dir in sway waybar foot wofi mako swaylock gtk-3.0 gtk-4.0 fastfetch; do
    [ -d "$CONFIG_DIR/$dir" ] && mv "$CONFIG_DIR/$dir" "$CONFIG_DIR/$dir.bak.$(date +%s)" 2>/dev/null
done

cp -r "$SCRIPT_DIR/config/sway" "$CONFIG_DIR/"
cp -r "$SCRIPT_DIR/config/waybar" "$CONFIG_DIR/"
cp -r "$SCRIPT_DIR/config/foot" "$CONFIG_DIR/"
cp -r "$SCRIPT_DIR/config/wofi" "$CONFIG_DIR/"
cp -r "$SCRIPT_DIR/config/mako" "$CONFIG_DIR/"
cp -r "$SCRIPT_DIR/config/swaylock" "$CONFIG_DIR/"
cp -r "$SCRIPT_DIR/config/gtk-3.0" "$CONFIG_DIR/"
cp -r "$SCRIPT_DIR/config/gtk-4.0" "$CONFIG_DIR/"
cp -r "$SCRIPT_DIR/config/fastfetch" "$CONFIG_DIR/"

# ============================================
# 14. SCRIPTS
# ============================================
log "Installing scripts..."
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/scripts/"* "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/"*

# ============================================
# 15. SUDOERS
# ============================================
log "Configuring sudoers..."
sudo tee /etc/sudoers.d/vlad-vpn > /dev/null << 'EOF'
vlad ALL=(root) NOPASSWD: /usr/bin/iptables
vlad ALL=(root) NOPASSWD: /home/vlad/.config/hysteria/iptables.sh
vlad ALL=(root) NOPASSWD: /sbin/shutdown
vlad ALL=(root) NOPASSWD: /sbin/reboot
EOF

# ============================================
# 16. DNS FIX
# ============================================
log "Fixing DNS (removing 0.0.0.0)..."
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf.head > /dev/null
sudo sed -i '/nameserver 0.0.0.0/d' /etc/resolv.conf 2>/dev/null || true

# ============================================
# 17. CURSOR ENV
# ============================================
log "Setting cursor environment..."
cat > "$HOME/.bash_profile" << 'BASHEOF'
# Cursor
export XCURSOR_THEME=Bibata-Modern-Ice
export XCURSOR_SIZE=20

# GTK
export GTK_THEME=Adwaita-dark
export GDK_SCALE=1
export GDK_DPI_SCALE=1

# Wayland
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export XDG_SESSION_TYPE=wayland

# Start Sway on TTY1
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec sway
fi
BASHEOF

# ============================================
# 18. GTK CURSOR
# ============================================
log "Setting GTK cursor..."
mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
cat > "$HOME/.config/gtk-3.0/settings.ini" << 'GTKEOF'
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
gtk-cursor-theme-name=Bibata-Modern-Ice
gtk-cursor-theme-size=20
gtk-font-name=DejaVu Sans 11
gtk-application-prefer-dark-theme=true
GTKEOF
cp "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"

mkdir -p "$HOME/.icons/default"
cat > "$HOME/.icons/default/index.theme" << 'CURSOREOF'
[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=Bibata-Modern-Ice
CURSOREOF

# ============================================
# 19. ENABLE SERVICES
# ============================================
log "Enabling services..."
sudo ln -sf /etc/sv/dbus /var/service/ 2>/dev/null || true
sudo ln -sf /etc/sv/chrony /var/service/ 2>/dev/null || true
sudo ln -sf /etc/sv/acpid /var/service/ 2>/dev/null || true
sudo ln -sf /etc/sv/elogind /var/service/ 2>/dev/null || true
sudo ln -sf /etc/sv/dockerd /var/service/ 2>/dev/null || true

# ============================================
# DONE
# ============================================
echo ""
echo "============================================"
log "Setup complete!"
echo ""
echo "  Reboot:  sudo reboot"
echo "  VPN:     Super+Alt+V (toggle)"
echo "  VPN:     Super+U (server picker)"
echo "  Menu:    Super+Space"
echo "  Terminal: Super+T"
echo "  Browser: Super+W"
echo "============================================"
