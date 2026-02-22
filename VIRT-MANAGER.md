# Virt-Manager Setup

This dotfiles repo includes complete virt-manager/libvirt configuration with working DNS and internet access for VMs.

## What's Installed

The `install.sh` script installs and configures:

- **libvirt** - Virtualization API and daemon
- **virt-manager** - GUI for managing VMs
- **qemu-full** - Full QEMU system emulator
- **dnsmasq** - DHCP and DNS server for VMs
- **edk2-ovmf** - UEFI firmware for VMs
- **swtpm** - TPM emulator (required for Windows 11)

## What's Configured

### 1. Libvirt Default Network
- **DNS forwarders**: 8.8.8.8, 1.1.1.1 (fixes DNS resolution in VMs)
- **DHCP range**: 192.168.122.2 - 192.168.122.254
- **NAT mode**: VMs get internet access through host

### 2. UFW Firewall Rules
The install script automatically configures UFW to allow:
- All traffic on `virbr0` interface (libvirt bridge)
- DNS queries to 192.168.122.1 (host dnsmasq)
- NAT routing from VMs to internet

**This fixes the common issue where VMs can ping IPs but DNS fails!**

### 3. Environment Configuration
- Sets `LIBVIRT_DEFAULT_URI=qemu:///system` system-wide
- Ensures virt-manager uses the system connection (not session)
- Adds user to `libvirt` group for VM management

## Installation

Run the install script with the `--backup` flag:

```bash
cd ~/dotfiles
./install.sh --backup
```

After installation:
1. **Log out and back in** (for libvirt group membership)
2. Launch virt-manager from your application menu
3. Create a VM - it will have working internet and DNS out of the box!

## Troubleshooting

### VMs can ping IPs but not resolve DNS

This was the original issue! The fix is already included in the configuration:

1. **DNS forwarders** in `/etc/libvirt/networks/default.xml`
2. **UFW rules** allowing DHCP, DNS, and NAT traffic
3. **Proper network mode** (NAT with masquerading)

### Check if everything is configured

```bash
# Verify libvirt network
virsh net-list --all
virsh net-dumpxml default

# Check UFW rules
sudo ufw status verbose

# Verify environment variable
echo $LIBVIRT_DEFAULT_URI  # Should be: qemu:///system
```

### Manual UFW configuration (if needed)

If you installed virt-manager before running this dotfiles install:

```bash
# Allow traffic on libvirt bridge
sudo ufw allow in on virbr0
sudo ufw allow out on virbr0

# Allow DNS to VMs
sudo ufw allow in on virbr0 to 192.168.122.1 port 53

# Allow NAT routing (replace wlan0 with your interface)
sudo ufw route allow in on virbr0 out on wlan0
```

## Technical Details

### The Problem
On Arch Linux with UFW enabled, VMs would:
- ✅ Get DHCP IP addresses
- ✅ Ping IP addresses (e.g., 8.8.8.8)
- ❌ Resolve DNS (ping google.com fails)
- ❌ Access HTTP/HTTPS websites

### The Root Cause
1. **UFW's default deny policy** blocked:
   - DHCP requests from VMs
   - DNS queries to host's dnsmasq
   - NAT/forwarded traffic to internet

2. **Missing DNS forwarders** in libvirt network config:
   - dnsmasq was using systemd-resolved's stub (127.0.0.53)
   - Stub resolver doesn't forward DNS for VM network

3. **Wrong connection mode**:
   - virt-manager defaulting to `qemu:///session` instead of `qemu:///system`

### The Solution
All three issues are fixed by this configuration:
1. UFW rules allow all necessary traffic
2. DNS forwarders (8.8.8.8, 1.1.1.1) configured in network XML
3. `LIBVIRT_DEFAULT_URI` set to `qemu:///system`

## Files Added

```
root/etc/libvirt/networks/default.xml  # Network config with DNS forwarders
root/etc/profile.d/libvirt.sh          # System-wide LIBVIRT_DEFAULT_URI
root/home/.config/fish/config.fish     # Fish shell environment variable
```

## References

- [Arch Wiki: Libvirt](https://wiki.archlinux.org/title/Libvirt)
- [Libvirt Networking](https://wiki.libvirt.org/Networking.html)
- [UFW with libvirt](https://wiki.archlinux.org/title/Libvirt#Using_nftables)
