# Void Linux + Sway WM Setup

Monochrome (black & white) Wayland desktop for HP Laptop 15s-eq1xxx.

## What's Inside

| Component | Details |
|-----------|---------|
| **OS** | Void Linux (runit), kernel 6.18 |
| **WM** | Sway 1.12 (Wayland) |
| **Bar** | Waybar |
| **Terminal** | Foot |
| **Launcher** | Wofi |
| **Notifications** | Mako |
| **Theme** | Monochrome black/white, Bibata-Modern-Ice cursor |
| **VPN** | sing-box 1.10.2, VLESS+Reality (Foxnezia) |
| **VPN Mode** | Transparent proxy (TUN, all apps) |

## Quick Start

```bash
git clone https://github.com/yourname/void-setup.git
cd void-setup
./install.sh
sudo reboot
```

## Keybindings

| Key | Action |
|-----|--------|
| `Super+T` | Terminal (Foot) |
| `Super+W` | Browser (Firefox) |
| `Super+D` | Telegram |
| `Super+E` | File manager (Nautilus) |
| `Super+Space` | App launcher (Wofi) |
| `Super+Q` | Kill window |
| `Super+X` | Lock screen |
| `Super+P` | Power menu |
| `Super+Alt+V` | Toggle VPN |
| `Super+U` | VPN server picker |
| `Super+Alt+C` | Clipboard history |
| `Super+Shift+S` | Screenshot |
| `Super+R` | Resize mode |

## VPN Setup

### How it works

- **sing-box 1.10.2** creates a TUN interface (`tun0`)
- All traffic automatically routes through VPN (transparent proxy)
- Uses **VLESS + Reality** protocol (looks like regular HTTPS)
- Servers from Foxnezia subscription (41 servers, 10 Reality)

### VPN Commands

```bash
vpn-toggle on              # Random alive server
vpn-toggle off             # Disconnect
vpn-toggle toggle          # Toggle on/off
vpn-toggle status          # Show status + IP
vpn-toggle list            # List Reality servers
vpn-toggle connect 5       # Connect to server #5
```

### VPN Server Picker

Press `Super+U` to open wofi menu:
1. Select a server from the list
2. Shows ping/latency
3. Confirm to connect

### VPN Files

| File | Description |
|------|-------------|
| `~/.config/sing-box/config.json` | sing-box config |
| `~/.local/bin/vpn-toggle` | VPN control script |
| `~/.local/bin/vpn-menu` | Wofi server picker |
| `~/.local/bin/sing-box-start` | sing-box launcher (ulimit fix) |
| `/tmp/vpn-status` | Current status |
| `/tmp/vpn-server-name` | Connected server name |

### Restoring sing-box

```bash
# Download sing-box 1.10.2
wget https://github.com/SagerNet/sing-box/releases/download/v1.10.2/sing-box-1.10.2-linux-amd64.tar.gz
tar xzf sing-box-1.10.2-linux-amd64.tar.gz
sudo cp sing-box-1.10.2-linux-amd64/sing-box /usr/local/bin/
sudo chmod +x /usr/local/bin/sing-box
```

### DNS Fix

If VPN stops working, check `/etc/resolv.conf`:
```bash
# Should have:
nameserver 1.1.1.1
nameserver 192.168.1.1

# Remove bad entries:
sudo sed -i '/nameserver 0.0.0.0/d' /etc/resolv.conf

# Prevent dhcpcd from overwriting:
sudo sh -c 'echo "nameserver 1.1.1.1" > /etc/resolv.conf.head'
```

## Color Scheme

Monochrome black & white:
- **Background**: `#000000`
- **Text**: `#ffffff`
- **Focused border**: `#ffffff`
- **Unfocused border**: `#222222`
- **Waybar**: `rgba(0, 0, 0, 0.85)` with rounded corners

## Custom Keymap

Dual Russian/English layout with CapsLock toggle:
- `/usr/share/kbd/keymaps/i386/qwerty/ru-en.map`
- Configured in sway: `xkb_layout "us,ru"` + `grp:caps_toggle`
- All hotkeys use `--to-code` (work with both layouts)

## Directory Structure

```
void-setup/
├── install.sh          # Automated installer
├── config/
│   ├── sway/           # Sway WM config
│   ├── waybar/         # Bar config + theme
│   ├── foot/           # Terminal config
│   ├── wofi/           # App launcher
│   ├── mako/           # Notifications
│   ├── swaylock/       # Lock screen
│   ├── gtk-3.0/        # GTK3 theme
│   ├── gtk-4.0/        # GTK4 theme
│   └── fastfetch/      # System info
├── scripts/
│   ├── vpn-toggle      # VPN control
│   ├── vpn-menu        # VPN server picker
│   ├── sing-box-start  # sing-box launcher
│   ├── bar-status      # Waybar status
│   ├── screenshot      # Screenshot tool
│   ├── power-menu      # Power menu
│   ├── ff              # Fastfetch wrapper
│   └── proxy-toggle    # Proxy toggle
├── keymaps/
│   └── ru-en.map       # Dual RU/EN keymap
├── wallpapers/
│   └── mt-fuji-bw.jpg  # Mt. Fuji wallpaper
└── docs/
    └── packages.txt    # Installed packages
```

## Hardware

- **Laptop**: HP 15s-eq1xxx
- **CPU**: AMD Athlon Silver 3050U
- **RAM**: 5.7 GB
- **GPU**: AMD Radeon (amdgpu)
- **WiFi**: Realtek RTL8821CE
- **Storage**: NVMe

## Troubleshooting

### VPN not connecting
```bash
# Check log
cat /tmp/sing-box.log

# Check status
cat /tmp/vpn-status

# Manual start
sudo pkill sing-box
sudo sing-box run -c ~/.config/sing-box/config.json
```

### Cursor not changing
```bash
# Force reload
export XCURSOR_THEME=Bibata-Modern-Ice
export XCURSOR_SIZE=20
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
gsettings set org.gnome.desktop.interface cursor-size 20
```

### Waybar not showing
```bash
# Restart
pkill waybar
waybar &
```
