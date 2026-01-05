# Switching Between iwd and wpa_supplicant on Arch Linux

This guide documents how to switch NetworkManager's WiFi backend between iwd and wpa_supplicant.

## Current Setup
- **WiFi Card**: Intel
- **Network Manager**: NetworkManager
- **TUI**: nmtui (via Waybar icon)

## Switch to wpa_supplicant (for eduroam compatibility)

### 1. Stop and disable iwd
```bash
sudo systemctl stop iwd
sudo systemctl disable iwd
sudo systemctl mask iwd  # Prevents it from auto-starting
```

### 2. Enable and start wpa_supplicant
```bash
sudo systemctl enable wpa_supplicant
sudo systemctl start wpa_supplicant
```

### 3. Configure NetworkManager to use wpa_supplicant backend
```bash
sudo mkdir -p /etc/NetworkManager/conf.d/
sudo tee /etc/NetworkManager/conf.d/wifi-backend.conf > /dev/null << 'EOF'
[device]
wifi.backend=wpa_supplicant
EOF
```

### 4. Restart NetworkManager
```bash
sudo systemctl restart NetworkManager
```

### 5. Verify
```bash
systemctl status wpa_supplicant
systemctl status iwd  # Should show "inactive"
nmcli device  # Should show your WiFi device
```

## Switch to iwd (for performance/simplicity)

### 1. Stop and disable wpa_supplicant
```bash
sudo systemctl stop wpa_supplicant
sudo systemctl disable wpa_supplicant
```

### 2. Enable and start iwd
```bash
sudo systemctl unmask iwd  # If previously masked
sudo systemctl enable iwd
sudo systemctl start iwd
```

### 3. Configure NetworkManager to use iwd backend
```bash
sudo tee /etc/NetworkManager/conf.d/wifi-backend.conf > /dev/null << 'EOF'
[device]
wifi.backend=iwd
EOF
```

### 4. Restart NetworkManager
```bash
sudo systemctl restart NetworkManager
```

### 5. Verify
```bash
systemctl status iwd
systemctl status wpa_supplicant  # Should show "inactive"
iwctl station wlan0 show
```

## Key Configuration File

**Location**: `/etc/NetworkManager/conf.d/wifi-backend.conf`

This file tells NetworkManager which WiFi backend to use:
- `wifi.backend=iwd` - Use iwd
- `wifi.backend=wpa_supplicant` - Use wpa_supplicant

## TUI Options by Backend

### With wpa_supplicant:
- **nmtui** (built-in) - Works perfectly, integrated with Waybar
- **nmcli** (command-line) - Full NetworkManager control

### With iwd:
- **impala** - Beautiful TUI specifically designed for iwd
  - Fast, minimal, keyboard-driven interface
  - **Limitation**: Only works with iwd, requires NetworkManager to be disabled or configured for iwd
  - Install: `pacman -S impala`

- **iwctl** (iwd's TUI) - iwd's built-in interactive management tool
  - Works standalone or with NetworkManager

- **nmtui** - Still works if NetworkManager is configured to use iwd backend

### Why wlctl Doesn't Work

**wlctl** is advertised as a NetworkManager-compatible fork of impala, but it has limitations:

- **Hardware compatibility**: wlctl appears to only work with Broadcom WiFi chipsets
- **Intel WiFi cards** (like the one in this system) are not supported
- This makes wlctl unsuitable as a general replacement for impala

**Conclusion**: For Intel WiFi cards, use:
- **impala** when using iwd backend
- **nmtui** when using wpa_supplicant backend

## Waybar/Omarchy Integration

The Waybar network icon is configured to launch a WiFi management TUI. This is controlled by:

**Configuration file**: `~/.local/share/omarchy/bin/omarchy-launch-wifi`

### Current Configuration (wpa_supplicant)

```bash
#!/bin/bash

rfkill unblock wifi
omarchy-launch-or-focus-tui nmtui
```

### Alternative Configuration (iwd with impala)

```bash
#!/bin/bash

rfkill unblock wifi
omarchy-launch-or-focus-tui impala
```

### Switching the Waybar TUI

When you switch WiFi backends, update this script:

```bash
nano ~/.local/share/omarchy/bin/omarchy-launch-wifi
```

Change line 4:
- For **wpa_supplicant**: `omarchy-launch-or-focus-tui nmtui`
- For **iwd**: `omarchy-launch-or-focus-tui impala`

Then reload Waybar:
```bash
killall waybar && waybar &
```

## Important Notes

1. **Only one backend can run at a time** - iwd and wpa_supplicant conflict if both try to manage WiFi
2. **eduroam compatibility** - SecureW2 JoinNow scripts work best with wpa_supplicant (see `eduroam.md`)
3. **After switching backends** - Always restart NetworkManager for changes to take effect
4. **Waybar integration** - Update `omarchy-launch-wifi` script to match your backend choice
5. **impala requires iwd** - If you want to use impala, you must use iwd backend
6. **wlctl incompatibility** - Don't use wlctl with Intel WiFi cards

## Troubleshooting

### iwd won't stop
```bash
sudo systemctl mask iwd
sudo systemctl stop iwd
```

### wpa_supplicant won't start
```bash
sudo systemctl unmask wpa_supplicant
sudo systemctl enable wpa_supplicant
sudo systemctl start wpa_supplicant
```

### Check which backend is active
```bash
nmcli -t -f GENERAL.STATE,GENERAL.CONNECTION device show wlan0
journalctl -u NetworkManager -n 50 | grep -i "wifi backend"
```

## References
- [NetworkManager - ArchWiki](https://wiki.archlinux.org/title/NetworkManager)
- [iwd - ArchWiki](https://wiki.archlinux.org/title/Iwd)
- [wpa_supplicant - ArchWiki](https://wiki.archlinux.org/title/Wpa_supplicant)
