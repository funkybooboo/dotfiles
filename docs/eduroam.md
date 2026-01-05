# eduroam Configuration on Arch Linux

## Overview

eduroam (education roaming) is an international WiFi network used by universities and research institutions. It uses WPA2-Enterprise with 802.1X authentication.

## Critical Requirement: wpa_supplicant

**eduroam requires wpa_supplicant as the NetworkManager WiFi backend.**

### Why wpa_supplicant is Required

1. **SecureW2 JoinNow Script Compatibility**
   - The SecureW2_JoinNow.run script (provided by USU and other institutions) is designed specifically for NetworkManager + wpa_supplicant
   - It does NOT support iwd directly

2. **Certificate Management**
   - eduroam uses EAP-TLS authentication with client certificates
   - The SecureW2 script automatically generates and configures certificates for wpa_supplicant
   - iwd requires manual certificate configuration in a different format

3. **Industry Standard**
   - Most eduroam configuration tools and scripts assume wpa_supplicant
   - wpa_supplicant has broader WPA2-Enterprise support

## Setup Process

### 1. Ensure wpa_supplicant Backend

Before running the eduroam configuration script, verify you're using wpa_supplicant:

```bash
# Check current backend
cat /etc/NetworkManager/conf.d/wifi-backend.conf
```

Should show:
```
[device]
wifi.backend=wpa_supplicant
```

If not, see `wifi-backend-switching.md` for instructions.

### 2. Run the SecureW2 JoinNow Script

```bash
cd ~/Downloads
./SecureW2_JoinNow.run
```

The script will:
1. Ask for a device name (e.g., "debbie")
2. Launch web authentication for SSO login
3. Generate a private key
4. Enroll and issue a client certificate
5. Configure NetworkManager with the credentials
6. Create the eduroam connection profile

### 3. Connect to eduroam

After the script completes:

```bash
# Using nmcli
nmcli connection up eduroam

# Or using nmtui
nmtui
```

## Configuration Files Created

The SecureW2 script creates:

1. **Certificate Directory**: `~/.joinnow/`
   - CA certificate (root certificate)
   - Client certificate (.crt file)
   - Private key (.p12 file)

2. **NetworkManager Connection**: `/etc/NetworkManager/system-connections/eduroam*`
   - Contains EAP-TLS configuration
   - References certificate files
   - Stores identity (e.g., A02386053@securew2.usu.edu)

## Authentication Details

- **SSID**: eduroam
- **Security**: WPA2-Enterprise
- **EAP Method**: TLS (certificate-based)
- **Identity**: Provided by SecureW2 (format: username@securew2.usu.edu)
- **Domain**: eduroam.usu.edu (for USU)

## Troubleshooting

### Connection Fails with "802.1X supplicant failed"

1. Verify wpa_supplicant is running:
   ```bash
   systemctl status wpa_supplicant
   ```

2. Check that iwd is stopped:
   ```bash
   systemctl status iwd  # Should show "inactive"
   ```

3. Verify NetworkManager backend:
   ```bash
   cat /etc/NetworkManager/conf.d/wifi-backend.conf
   ```

### Certificate Issues

If certificates are missing or corrupt:

1. Remove old configuration:
   ```bash
   nmcli connection delete eduroam
   rm -rf ~/.joinnow
   ```

2. Re-run the SecureW2 script:
   ```bash
   cd ~/Downloads
   ./SecureW2_JoinNow.run
   ```

### Script Says "Network not in range"

This message can be misleading. Even if eduroam appears in your WiFi scan, the script may show this. Try:

```bash
# Check if eduroam is visible
nmcli device wifi list | grep eduroam

# Try connecting manually
nmcli connection up eduroam
```

## Switching Back to Regular Networks

You can use other WiFi networks while eduroam is configured:

```bash
# Connect to regular WiFi
nmcli device wifi connect "SSID" password "password"

# Or use nmtui
nmtui
```

The eduroam connection profile remains configured and can be activated when needed.

## Re-enrollment

eduroam certificates typically expire after 1-2 years. When they expire:

1. Delete the old connection:
   ```bash
   nmcli connection delete eduroam
   rm -rf ~/.joinnow
   ```

2. Re-run the SecureW2 script to get new certificates

## Important Notes

- **Do not share** the files in `~/.joinnow/` - they contain your personal credentials
- **Backup** the `~/.joinnow/` directory if you want to use the same certificates on multiple devices
- The eduroam connection works automatically across all eduroam-enabled institutions worldwide
- Some institutions may have different configuration requirements - check with your IT department

## References

- [Utah State University eduroam](https://it.usu.edu/eduroam)
- [eduroam Official Site](https://www.eduroam.org/)
- [SecureW2 Documentation](https://www.securew2.com/)
- [NetworkManager - ArchWiki](https://wiki.archlinux.org/title/NetworkManager)
