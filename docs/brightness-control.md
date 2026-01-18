# Brightness Control

## Overview
Custom brightness control system with intelligent step sizing and minimum brightness protection.

## Configuration
- **Control Tool:** Brightnessctl 0.5.1-3
- **OSD Display:** SwayOSD 0.2.1-2
- **Wrapper Script:** `~/.local/bin/omarchy-cmd-brightness`
- **Key Bindings:** `~/.config/hypr/bindings.conf`

## Behavior
- **Step Size:** 5% (jumps in increments of 5)
- **Minimum Brightness:** 1% (never goes to 0%)
- **Brightness Levels:** 1%, 5%, 10%, 15%, 20%, ..., 95%, 100%

## Smart Stepping Logic
- **From 1% → Up:** Jumps directly to 5% (not 6%)
- **From 5% → Down:** Drops to 1% (not 0%)
- **All Other Levels:** Normal 5% increments maintained
- **Result:** Brightness always aligns to multiples of 5, except for 1% minimum

## Key Bindings

**Normal brightness adjustment (5% steps):**
- `XF86MonBrightnessUp` - Increase brightness by 5%
- `XF86MonBrightnessDown` - Decrease brightness by 5%

**Precise brightness adjustment (1% steps):**
- `Alt + XF86MonBrightnessUp` - Increase brightness by 1%
- `Alt + XF86MonBrightnessDown` - Decrease brightness by 1%

## Technical Details

**Brightness Scale:**
- Maximum value: 96000 (device-specific)
- 1% = 960 units
- 5% = 4800 units

**Wrapper Script Features:**
- Prevents brightness from going below 1%
- Snaps values to multiples of 5
- Special case handling for 1% → 5% transition
- Displays OSD feedback via SwayOSD

**Files:**
- Script: `~/.local/bin/omarchy-cmd-brightness`
- Bindings: `~/.config/hypr/bindings.conf`
- Dotfiles Source (script): `~/dotfiles/home/.local/bin/omarchy-cmd-brightness`
- Dotfiles Source (bindings): `~/dotfiles/home/.config/hypr/bindings.conf`

**Note:** These files are update-proof and won't be affected by omarchy updates. The script is in PATH and takes precedence over omarchy's default, and the bindings are in user config which overrides omarchy defaults.

## Manual Control

**Set brightness directly:**
```bash
brightnessctl set 50%     # Set to 50%
brightnessctl set 48000   # Set to specific value
```

**Increase/decrease by amount:**
```bash
brightnessctl set +10%    # Increase by 10%
brightnessctl set -10%    # Decrease by 10%
```

**View current brightness:**
```bash
brightnessctl info
brightnessctl get         # Get current value
```

## Troubleshooting

**If brightness keys don't work:**
1. Check if brightnessctl works: `brightnessctl info`
2. Reload Hyprland config: `hyprctl reload`
3. Check wrapper script permissions: `ls -l ~/.local/bin/omarchy-cmd-brightness`
4. Verify script is in PATH: `which omarchy-cmd-brightness`

**If OSD doesn't appear:**
1. Check if SwayOSD is running: `pgrep swayosd`
2. Restart SwayOSD service: `systemctl --user restart swayosd`
