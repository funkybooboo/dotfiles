# VPN Setup and Management

## Overview

Unified VPN management system supporting multiple VPN types through a single `vpn` command.

## Available VPNs

### 1. Home VPN (debbie-local)
- **Type:** NetworkManager WireGuard
- **Connection Name:** debbie-local
- **Purpose:** Secure connection to home network
- **Use Case:** Access NAS and home services remotely

### 2. Proton VPN
- **Type:** Proton VPN CLI
- **Purpose:** Privacy and secure browsing
- **Use Case:** Public networks, privacy protection

## VPN Command Usage

### Check Status

Show status of all configured VPNs:

```bash
vpn status
```

Example output:
```
=== VPN Status ===

● home (debbie-local) - ACTIVE
  IP: 10.0.0.2/24
○ proton - inactive

No VPN connections active
```

### List Available VPNs

```bash
vpn list
```

Shows all VPNs with their current status and autoconnect settings:
```
Available VPNs:
  ● home (debbie-local) - active [autoconnect]
  ○ proton - inactive
```

### Connect to VPN

```bash
vpn up home     # Connect to home network
vpn up proton   # Connect to Proton VPN
```

### Disconnect from VPN

```bash
vpn down home   # Disconnect specific VPN
vpn down        # Disconnect all VPNs
```

### Switch VPNs

Automatically disconnect all VPNs and connect to the specified one:

```bash
vpn switch proton   # Switch to Proton VPN
vpn switch home     # Switch to home VPN
```

### Auto-Connect on Boot

Toggle autoconnect for VPNs:

```bash
vpn autoconnect home    # Toggle home VPN autoconnect
vpn autoconnect proton  # Toggle Proton VPN autoconnect
```

**Note:** Only one VPN should have autoconnect enabled to avoid conflicts.

## Initial Setup

### Home VPN (WireGuard)

1. **Obtain WireGuard configuration from your home server**

2. **Import into NetworkManager:**

```bash
sudo nmcli connection import type wireguard file /path/to/debbie-local.conf
```

3. **Rename connection (if needed):**

```bash
sudo nmcli connection modify "WireGuard Connection" connection.id debbie-local
```

4. **Enable autoconnect (optional):**

```bash
vpn autoconnect home
```

### Proton VPN

1. **Install Proton VPN CLI:**

```bash
yay -S proton-vpn-cli
```

2. **Login to Proton VPN:**

```bash
protonvpn login
```

Enter your Proton VPN credentials.

3. **Initialize configuration:**

```bash
protonvpn configure
```

Select your preferred settings (protocol, DNS, etc.)

4. **Test connection:**

```bash
vpn up proton
```

5. **Enable autoconnect (optional):**

```bash
vpn autoconnect proton
```

## VPN Script Configuration

The VPN definitions are in `~/.local/bin/vpn/vpn`:

```bash
declare -A VPNS=(
    ["home"]="nm:debbie-local"      # NetworkManager connection
    ["proton"]="protonvpn"           # Proton VPN CLI
)
```

### Adding a New VPN

To add a new VPN to the manager:

1. **Edit the VPN script:**

```bash
vim ~/.local/bin/vpn/vpn
```

2. **Add to VPNS array:**

```bash
declare -A VPNS=(
    ["home"]="nm:debbie-local"
    ["proton"]="protonvpn"
    ["work"]="nm:work-vpn"           # Add new VPN
)
```

3. **Save and test:**

```bash
vpn list
vpn up work
```

## Autoconnect Behavior

### Home VPN (NetworkManager)
- Uses NetworkManager's built-in autoconnect
- Connects immediately when network is available
- Persists across reboots

### Proton VPN (Systemd Service)
- Creates a systemd user service
- Connects on user login
- Service file: `~/.config/systemd/user/protonvpn-autoconnect.service`

## Common Use Cases

### Working from Home

```bash
vpn status              # Check current status
vpn down                # Disconnect all VPNs
```

### Remote Access to NAS

```bash
vpn up home             # Connect to home network
# Now access NAS at 192.168.8.238
```

### Public WiFi

```bash
vpn up proton           # Connect to Proton VPN for privacy
```

### Switching Contexts

```bash
vpn switch home         # Switch from any VPN to home
vpn switch proton       # Switch to Proton VPN
```

## Integration with NAS Sync

When working remotely:

1. **Connect to home VPN:**
   ```bash
   vpn up home
   ```

2. **NAS sync will automatically work** because NAS becomes reachable at 192.168.8.238

3. **Manual sync if needed:**
   ```bash
   ~/.local/bin/sync/nas/sync-documents
   ```

## Troubleshooting

### Connection Fails

Check VPN configuration:
```bash
# For home VPN
nmcli connection show debbie-local

# For Proton VPN
protonvpn status
```

### Multiple VPNs Active

This can cause routing conflicts. Disconnect all and connect to one:
```bash
vpn down
vpn up home
```

### Autoconnect Issues

Check autoconnect status:
```bash
# Home VPN
nmcli -g connection.autoconnect connection show debbie-local

# Proton VPN
systemctl --user status protonvpn-autoconnect.service
```

### Proton VPN Not Working

Reinstall and reconfigure:
```bash
yay -S proton-vpn-cli
protonvpn login
protonvpn configure
```

### DNS Leaks

Test for DNS leaks:
```bash
# With VPN connected
dig +short myip.opendns.com @resolver1.opendns.com
```

Should show VPN IP, not your real IP.

### Can't Access Home Network

Verify home VPN is connected:
```bash
vpn status
ping 192.168.8.238      # NAS IP
```

## Advanced Configuration

### Split Tunneling

For NetworkManager VPNs, configure routes:

```bash
# Only route specific subnets through VPN
nmcli connection modify debbie-local +ipv4.routes "192.168.8.0/24"
nmcli connection modify debbie-local ipv4.never-default yes
```

### DNS Configuration

Set custom DNS for VPN:

```bash
# Home VPN
nmcli connection modify debbie-local ipv4.dns "192.168.8.1"
nmcli connection modify debbie-local ipv4.ignore-auto-dns yes
```

### Kill Switch

Enable kill switch for Proton VPN:

```bash
protonvpn configure
# Select "Enable Kill Switch" option
```

## Files

**VPN Manager:**
- Script: `~/.local/bin/vpn/vpn`
- Dotfiles: `~/dotfiles/home/.local/bin/vpn/vpn`

**NetworkManager Connections:**
- Home VPN: `/etc/NetworkManager/system-connections/debbie-local.nmconnection`

**Proton VPN:**
- Config: `~/.config/protonvpn/`
- Autoconnect: `~/.config/systemd/user/protonvpn-autoconnect.service`

## Security Notes

- VPN credentials stored by NetworkManager are encrypted
- Proton VPN credentials stored in system keyring
- WireGuard private keys stored with restricted permissions
- Always verify VPN is connected before transmitting sensitive data
- Use kill switch to prevent traffic leaks if VPN drops

## Quick Reference

```bash
vpn status                  # Show all VPN statuses
vpn list                    # List available VPNs
vpn up home                 # Connect to home
vpn up proton               # Connect to Proton
vpn down                    # Disconnect all
vpn switch proton           # Switch to Proton
vpn autoconnect home        # Toggle home autoconnect
```
