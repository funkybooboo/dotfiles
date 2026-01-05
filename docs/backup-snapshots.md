# Backup & Snapshot System

## Overview
Your system uses **Btrfs snapshots** with **Snapper** for instant, space-efficient backups. Snapshots are integrated with the **Limine bootloader**, allowing you to boot directly from any snapshot to restore your system.

## Technology Stack
- **Filesystem:** Btrfs (supports instant copy-on-write snapshots)
- **Snapshot Manager:** Snapper 0.13.0-2
- **Bootloader Integration:** Limine Snapper Sync 1.18.1-1
- **Boot Entries:** Up to 5 most recent snapshots appear in bootloader

## Snapshot Configurations
Two independent snapshot configs are active:

1. **root** - System snapshots (/)
   - Config file: `/etc/snapper/configs/root`
   - Snapshot location: `/.snapshots/`
   - Max snapshots: 5 regular + 5 important

2. **home** - Home directory snapshots (/home)
   - Config file: `/etc/snapper/configs/home`
   - Snapshot location: `/home/.snapshots/`
   - Max snapshots: 5 regular + 5 important

## Settings
- **Automatic timeline snapshots:** Disabled (manual only)
- **Number cleanup:** Enabled (keeps max 5 snapshots)
- **Space limit:** 50% of filesystem
- **Free space requirement:** 20% must remain free

## Commands

**Create a snapshot:**
```bash
omarchy-snapshot create
```
Creates numbered snapshots for both root and home configs.

**Restore from a snapshot:**
```bash
omarchy-snapshot restore
```
Opens bootloader menu to select and boot from a previous snapshot.

**View snapshots:**
```bash
sudo snapper -c root list    # View system snapshots
sudo snapper -c home list    # View home snapshots
sudo snapper list-configs    # View all configs
```

**Delete a snapshot:**
```bash
sudo snapper -c root delete <number>    # Delete system snapshot
sudo snapper -c home delete <number>    # Delete home snapshot
```

**Compare snapshots:**
```bash
sudo snapper -c root status <number1>..<number2>
sudo snapper -c root diff <number1>..<number2>
```

## Best Practices

**When to create snapshots:**
- Before major system updates (`pacman -Syu`)
- Before installing new software
- Before making system configuration changes
- Before experimenting with the system
- After successful major changes (mark as "important")

**Snapshot workflow:**
```bash
# Before making changes
omarchy-snapshot create

# Make your changes
sudo pacman -S some-package

# If something breaks, reboot and select snapshot from bootloader
# Or manually restore files from /.snapshots/<number>/snapshot/
```

## Recovery Process

**Option 1: Boot from snapshot (full system restore)**
1. Reboot your system
2. In the Limine bootloader, select "Snapshots"
3. Choose the snapshot you want to boot
4. System boots from the selected snapshot state

**Option 2: Restore individual files**
```bash
# Snapshots are accessible at /.snapshots/<number>/snapshot/
# Browse and copy files manually
sudo cp /.snapshots/42/snapshot/etc/some-config /etc/some-config
```

**Option 3: Full restore via command**
```bash
omarchy-snapshot restore
# Follow the prompts to select and restore a snapshot
```

## Monitoring Snapshots

**Check snapshot disk usage:**
```bash
sudo btrfs filesystem df /
sudo btrfs filesystem usage /
```

**View snapshot details:**
```bash
sudo snapper -c root list
# Shows: Type, Pre#, Date, User, Description
```

## Automation

The `limine-snapper-sync` service automatically:
- Updates bootloader entries when snapshots are created/deleted
- Maintains up to 5 snapshot entries in the boot menu
- Syncs on every kernel update or manual snapshot creation

## Advanced Usage

**Create a pre/post snapshot pair:**
```bash
# Create pre-snapshot before making changes
sudo snapper -c root create --type pre --cleanup-algorithm number --print-number --description "Before update"

# Make your changes here...

# Create post-snapshot (use the number from pre-snapshot)
sudo snapper -c root create --type post --pre-number <pre-number> --cleanup-algorithm number --description "After update"
```

**Mark a snapshot as important:**
```bash
sudo snapper -c root modify --cleanup-algorithm important <number>
```

**View differences between snapshots:**
```bash
# Show changed files
sudo snapper -c root status 1..2

# Show actual file differences
sudo snapper -c root diff 1..2
```

## Troubleshooting

**If snapshots aren't appearing in bootloader:**
```bash
sudo systemctl status limine-snapper-sync
sudo limine-update
```

**If snapshot creation fails:**
```bash
# Check Btrfs status
sudo btrfs filesystem show
sudo btrfs filesystem usage /

# Check snapper configuration
sudo snapper list-configs
```

**Cleanup old snapshots manually:**
```bash
sudo snapper -c root cleanup number
```
