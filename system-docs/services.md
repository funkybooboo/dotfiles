# System Services

## Running Services (25 services)

### Core System Services
1. **systemd-journald** - Journal/logging service
2. **systemd-logind** - User login management
3. **systemd-udevd** - Device event management
4. **systemd-userdbd** - User database manager
5. **systemd-networkd** - Network configuration
6. **systemd-resolved** - DNS resolution
7. **systemd-timesyncd** - Time synchronization
8. **dbus-broker** - D-Bus message bus

### Display & Session
9. **sddm** - Simple Desktop Display Manager

### Network Services
10. **NetworkManager** - Network connection manager
11. **iwd** - Intel wireless daemon
12. **avahi-daemon** - mDNS/DNS-SD (network discovery)

### Security & Authentication
13. **polkit** - Authorization manager

### Power Management
14. **upower** - Power management daemon
15. **power-profiles-daemon** - Power profiles (performance/balanced/power-saver)
16. **rtkit-daemon** - Realtime scheduling for audio

### VPN
17. **proton.VPN** - Proton VPN daemon

### Bluetooth
18. **bluetooth** - Bluetooth service

### Printing
19. **cups** - CUPS print scheduler
20. **cups-browsed** - Remote CUPS printer discovery

### Containers
21. **docker** - Docker container engine
22. **containerd** - Container runtime

### Battery Monitoring
23. **batmond** - Battery level monitoring and logging

### Boot Management
24. **limine-snapper-sync** - Syncs boot entries with Snapper snapshots

### User Session
25. **user@1000** - User session for UID 1000

---

## Enabled Services (21 services)

Services set to start automatically on boot:

1. avahi-daemon
2. bluetooth
3. cups / cups-browsed
4. docker
5. getty@ (console login)
6. iwd
7. limine-snapper-sync
8. NetworkManager (+ dispatcher, wait-online)
9. nvidia-hibernate/resume/suspend (NVIDIA power management)
10. proton.VPN
11. sddm
12. systemd-network-generator
13. systemd-networkd
14. systemd-resolved
15. systemd-timesyncd
16. ufw (firewall)

---

## Service Management

### View running services:
```bash
systemctl list-units --type=service --state=running
```

### View enabled services:
```bash
systemctl list-unit-files --type=service --state=enabled
```

### Enable/disable a service:
```bash
sudo systemctl enable <service>
sudo systemctl disable <service>
```

### Start/stop a service:
```bash
sudo systemctl start <service>
sudo systemctl stop <service>
```

### Check service status:
```bash
systemctl status <service>
```

### View service logs:
```bash
journalctl -u <service>
journalctl -u <service> -f  # Follow logs
```
