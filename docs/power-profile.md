# Power Profile Auto-Switching

## Overview
Automated power profile management that switches between performance and power-saver modes based on AC adapter state.

## Configuration
- **Switching Script:** `~/.local/lib/power-profile-switch`
- **Systemd Service:** `~/.config/systemd/user/power-profile-switch.service`
- **Udev Rule:** `/etc/udev/rules.d/99-power-profile.rules`
- **Power Profiles Daemon:** `power-profiles-daemon.service`

## Behavior
- **On Battery:** Automatically switches to `power-saver` profile
- **Plugged In:** Automatically switches to `performance` profile
- **Instant Switching:** Triggers immediately when AC adapter state changes
- **System Logging:** All switches are logged to systemd journal

## Available Profiles
The system has three power profiles managed by `power-profiles-daemon`:
- **performance** - Maximum performance, higher power consumption
- **balanced** - Balance between performance and power saving
- **power-saver** - Maximum power saving, reduced performance

## Technical Details

**AC Adapter Detection:**
- Path: `/sys/class/power_supply/ACAD/online`
- State: `1` = plugged in, `0` = on battery

**Power Profile Control:**
- Command: `powerprofilesctl set <profile>`
- Daemon: `power-profiles-daemon.service`

**Trigger Mechanism:**
- Udev monitors power supply subsystem changes
- On AC state change, udev triggers systemd user service
- Service runs the switch script as the user

**Files:**
- Script: `~/.local/lib/power-profile-switch`
- Service: `~/.config/systemd/user/power-profile-switch.service`
- Udev Rule: `/etc/udev/rules.d/99-power-profile.rules`
- Dotfiles Source: `~/dotfiles/home/.local/lib/power-profile-switch`

## Service Management

**Check current power profile:**
```bash
powerprofilesctl
powerprofilesctl list
```

**Manually set power profile:**
```bash
powerprofilesctl set performance
powerprofilesctl set balanced
powerprofilesctl set power-saver
```

**Check AC adapter state:**
```bash
cat /sys/class/power_supply/ACAD/online
```

**View switching logs:**
```bash
journalctl --user -u power-profile-switch.service
journalctl --user -u power-profile-switch.service -f  # Follow logs
journalctl | grep "Power profile"  # View system logs
```

**Check udev rule is active:**
```bash
udevadm control --reload-rules
udevadm trigger --subsystem-match=power_supply
```

## Manual Testing

**Run script manually:**
```bash
~/.local/lib/power-profile-switch
```

**Check current battery/AC status:**
```bash
cat /sys/class/power_supply/ACAD/online
cat /sys/class/power_supply/BAT0/status
```

**Manually trigger udev event:**
```bash
sudo udevadm trigger --subsystem-match=power_supply
```

**Test by plugging/unplugging AC:**
1. Check current profile: `powerprofilesctl`
2. Unplug AC adapter
3. Wait 1-2 seconds
4. Check profile again: `powerprofilesctl`
5. Should now be on `power-saver`

**Monitor logs during testing:**
```bash
journalctl --user -u power-profile-switch.service -f
```

## Troubleshooting

**If profile doesn't switch automatically:**
1. Check if udev rule exists: `ls -l /etc/udev/rules.d/99-power-profile.rules`
2. Check if power-profiles-daemon is running: `systemctl status power-profiles-daemon`
3. Reload udev rules: `sudo udevadm control --reload-rules`
4. Trigger udev manually: `sudo udevadm trigger --subsystem-match=power_supply`
5. Check logs: `journalctl --user -u power-profile-switch.service -n 20`

**If AC adapter path is wrong:**
1. Find your AC adapter: `ls /sys/class/power_supply/`
2. Edit the script and update the find command if needed

**If permission errors occur:**
1. Ensure script is executable: `chmod +x ~/.local/lib/power-profile-switch`
2. Check if user can set profiles: `powerprofilesctl set balanced`

**If udev rule isn't triggering:**
1. Check udev rule syntax: `cat /etc/udev/rules.d/99-power-profile.rules`
2. Test udev monitoring: `udevadm monitor --subsystem-match=power_supply`
3. Plug/unplug AC and watch for events

**To disable auto-switching:**
1. Remove or rename udev rule: `sudo mv /etc/udev/rules.d/99-power-profile.rules{,.disabled}`
2. Reload udev: `sudo udevadm control --reload-rules`
3. Manually set preferred profile: `powerprofilesctl set balanced`

## Installation

The power profile automation is automatically installed by `setup.sh`:

**Manual installation:**
```bash
# Install udev rule
sudo cp ~/dotfiles/root/etc/udev/rules.d/99-power-profile.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=power_supply

# Script and service are linked by setup.sh
# Or manually:
# ln -s ~/dotfiles/home/.local/lib/power-profile-switch ~/.local/lib/
# ln -s ~/dotfiles/home/.config/systemd/user/power-profile-switch.service ~/.config/systemd/user/
```

## Notes

- The automation does NOT require the systemd service to be enabled, as it's triggered on-demand by udev
- Initial profile on boot depends on AC state at boot time
- The script uses the first AC adapter found (ACAD, AC0, AC1, ADP0, ADP1, etc.)
- Profile changes are logged to both systemd journal and syslog
