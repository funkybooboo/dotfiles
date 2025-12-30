# Omarchy Configuration Files

This directory contains **all** custom configuration files and scripts for the Omarchy desktop environment.

## Directory Structure

```
omarchy/
├── bin/              # All omarchy utility scripts (141 files)
└── hypr/             # Hyprland configuration files (27 files)
    ├── apps/         # Application-specific rules
    ├── bindings/     # Key bindings (including custom media.conf)
    └── *.conf        # Various hypr configs
```

## Key Customizations

### Custom Brightness Control (`bin/omarchy-cmd-brightness`)

Modified script with:
- Brightness jumps in 5% increments (instead of 1%)
- Minimum brightness of 1% (never goes to 0%)
- Smart stepping: 1% → 5% when increasing, 5% → 1% when decreasing
- Brightness levels align to multiples of 5 (except 1% minimum)

### Custom Media Bindings (`hypr/bindings/media.conf`)

Modified Hyprland media key bindings with:
- Custom brightness control (5% steps)
- Volume control via SwayOSD
- Media key integration with Playerctl

## Deployment

When you run `./setup.sh`, all files are automatically symlinked:

- `omarchy/bin/*` → `~/.local/share/omarchy/bin/*` (141 scripts)
- `omarchy/hypr/*` → `~/.local/share/omarchy/default/hypr/*` (27 configs, preserving directory structure)

## Setup Commands

```bash
cd ~/dotfiles
./setup.sh --dry-run    # Preview what will be linked
./setup.sh --backup     # Backup existing files before linking
./setup.sh --force      # Overwrite existing files
```

## Documentation

For detailed information about the brightness control system, see:
- [Brightness Control Documentation](../system-docs/brightness-control.md)

## Version Control

All omarchy customizations are now tracked in git, making them:
- Portable across systems
- Version controlled
- Backed up with dotfiles
- Easy to restore/deploy
