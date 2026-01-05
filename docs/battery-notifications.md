# Battery Notifications

## Overview
Automated battery monitoring system that sends desktop notifications when battery level crosses specific thresholds while discharging.

## Configuration
- **Monitoring Script:** `~/.local/lib/battery-notify`
- **Systemd Service:** `~/.config/systemd/user/battery-notify.service`
- **Systemd Timer:** `~/.config/systemd/user/battery-notify.timer`
- **State File:** `~/.cache/battery-notify-state`
- **Check Interval:** Every 2 minutes

## Notification Thresholds
The system notifies at the following battery levels:
- **80%** - Normal priority
- **50%** - Normal priority
- **30%** - Normal priority
- **20%** - Normal priority
- **10%** - Critical priority
- **5%** - Critical priority
- **1%** - Critical priority

## Behavior
- **Single Notification:** Each threshold triggers only once per discharge cycle
- **Auto-Reset:** When charging or battery is full, the system resets to allow new notifications
- **Smart Detection:** Only monitors when battery is discharging
- **No Spam:** Won't send duplicate notifications at the same threshold

## Technical Details

**Battery Detection:**
- Primary: `/sys/class/power_supply/BAT0`
- Fallback: `/sys/class/power_supply/BAT1`

**Notification Urgency:**
- Levels ≤10%: Critical urgency with caution icon
- Levels ≤30%: Normal urgency with low battery icon
- Levels >30%: Normal urgency with good battery icon

**State Management:**
- State file tracks the last notified threshold
- Prevents duplicate notifications
- Automatically resets when charging detected

**Files:**
- Script: `~/.local/lib/battery-notify`
- Service: `~/.config/systemd/user/battery-notify.service`
- Timer: `~/.config/systemd/user/battery-notify.timer`
- Dotfiles Source: `~/dotfiles/home/.local/lib/battery-notify`

## Service Management

**Check status:**
```bash
systemctl --user status battery-notify.timer
systemctl --user status battery-notify.service
```

**View logs:**
```bash
journalctl --user -u battery-notify.service
journalctl --user -u battery-notify.service -f  # Follow logs
```

**Stop notifications:**
```bash
systemctl --user stop battery-notify.timer
```

**Start notifications:**
```bash
systemctl --user start battery-notify.timer
```

**Disable on startup:**
```bash
systemctl --user disable battery-notify.timer
```

**Enable on startup:**
```bash
systemctl --user enable battery-notify.timer
```

**Restart service:**
```bash
systemctl --user restart battery-notify.timer
```

## Manual Testing

**Run script manually:**
```bash
~/.local/lib/battery-notify
```

**Check current battery level:**
```bash
cat /sys/class/power_supply/BAT0/capacity
cat /sys/class/power_supply/BAT0/status
```

**Reset notification state (to re-trigger notifications):**
```bash
echo "100" > ~/.cache/battery-notify-state
```

**Force a test notification:**
```bash
notify-send -u critical -i battery-caution "Battery Alert" "Battery at 10%"
```

## Troubleshooting

**If notifications don't appear:**
1. Check if timer is running: `systemctl --user status battery-notify.timer`
2. Check if notification daemon is running: `pgrep -a notification` or `pgrep -a dunst`
3. Test notification manually: `notify-send "Test" "This is a test"`
4. Check script logs: `journalctl --user -u battery-notify.service -n 20`

**If battery path is wrong:**
1. Find your battery path: `ls /sys/class/power_supply/`
2. Edit the script and update `BATTERY_PATH` if needed

**If notifications trigger repeatedly:**
1. Check state file: `cat ~/.cache/battery-notify-state`
2. Reset state: `echo "100" > ~/.cache/battery-notify-state`

**If timer doesn't start on boot:**
1. Enable the timer: `systemctl --user enable battery-notify.timer`
2. Check if enabled: `systemctl --user is-enabled battery-notify.timer`
