# NAS Sync Setup

## Overview

Automated bidirectional synchronization between local directories and NAS using rsync over the network. Sync runs hourly via systemd timers.

## NAS Configuration

- **NAS IP:** 192.168.8.238
- **Port:** 873 (rsync)
- **Protocol:** rsync over TCP

## Synced Directories

Four directories are automatically synced:

1. **Documents** - `~/Documents`
2. **Music** - `~/Music`
3. **Photos** - `~/Pictures`
4. **Audiobooks** - `~/Audiobooks`

## Initial Setup

### 1. Create Password File

The setup script will prompt for your NAS rsync password, or create it manually:

```bash
mkdir -p ~/.config/nas-sync
echo 'your_nas_password' > ~/.config/nas-sync/rsync-password
chmod 600 ~/.config/nas-sync/rsync-password
```

### 2. Run Setup Script

The dotfiles setup script automatically configures NAS sync:

```bash
cd ~/dotfiles
./setup.sh
```

This will:
- Create the password file (if you provide it)
- Enable systemd timers for all sync types
- Start the timers

### 3. Verify Setup

Check that timers are running:

```bash
systemctl --user list-timers | grep nas-sync
```

You should see four timers:
- nas-sync-documents.timer
- nas-sync-music.timer
- nas-sync-photos.timer
- nas-sync-audiobooks.timer

## Manual Sync

Run a one-time sync for any directory:

```bash
# Documents
~/.local/bin/nas/sync-documents

# Music
~/.local/bin/nas/sync-music

# Photos
~/.local/bin/nas/sync-photos

# Audiobooks
~/.local/bin/nas/sync-audiobooks
```

## Sync Schedule

Each directory syncs on this schedule:

- **First sync:** 5 minutes after boot
- **Recurring:** Every 1 hour
- **Accuracy:** Within 5 minutes

## How Sync Works

The sync is **bidirectional** with the following process:

1. **Upload:** Local changes pushed to NAS
2. **Download:** NAS changes pulled to local
3. **Delete sync:** Files deleted on either side are removed from both

**Rsync options used:**
- `-a` - Archive mode (preserves permissions, times, ownership)
- `-v` - Verbose output
- `-z` - Compress during transfer
- `-u` - Skip files newer on receiver
- `--delete` - Remove files that don't exist on sender
- `--progress` - Show transfer progress

## Network Check

Before each sync, the system checks if the NAS is reachable:

```bash
~/.local/bin/nas/check-nas-connection
```

If the NAS is unreachable, the sync is skipped (not an error).

## Monitoring Sync

### View Timer Status

```bash
systemctl --user list-timers
```

### View Last Sync

```bash
systemctl --user status nas-sync-documents.service
```

### Follow Sync Logs

```bash
journalctl --user -u nas-sync-documents.service -f
```

### View All NAS Sync Logs

```bash
journalctl --user -u "nas-sync-*" --since "1 hour ago"
```

## Managing Timers

### Enable/Disable Specific Sync

```bash
# Disable documents sync
systemctl --user stop nas-sync-documents.timer
systemctl --user disable nas-sync-documents.timer

# Re-enable
systemctl --user enable nas-sync-documents.timer
systemctl --user start nas-sync-documents.timer
```

### Disable All Syncs

```bash
systemctl --user stop nas-sync-*.timer
systemctl --user disable nas-sync-*.timer
```

## Adding New Sync Directories

To add a new directory to sync:

1. **Create sync script:**

```bash
cat > ~/.local/bin/nas/sync-newdir << 'EOF'
#!/usr/bin/env bash
# Sync NewDir with NAS
exec "$HOME/.local/bin/nas/sync-to-nas" "$HOME/NewDir" "newdir" "nate"
EOF
chmod +x ~/.local/bin/nas/sync-newdir
```

2. **Create systemd service:**

```bash
cat > ~/.config/systemd/user/nas-sync-newdir.service << EOF
[Unit]
Description=Sync NewDir with NAS
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=%h/.local/bin/nas/sync-newdir
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF
```

3. **Create systemd timer:**

```bash
cat > ~/.config/systemd/user/nas-sync-newdir.timer << EOF
[Unit]
Description=Hourly NewDir sync with NAS
Requires=nas-sync-newdir.service

[Timer]
OnBootSec=5min
OnUnitActiveSec=1h
AccuracySec=5min

[Install]
WantedBy=timers.target
EOF
```

4. **Enable the timer:**

```bash
systemctl --user daemon-reload
systemctl --user enable nas-sync-newdir.timer
systemctl --user start nas-sync-newdir.timer
```

## NAS Module Configuration

On the NAS side, rsync modules must be configured in `/etc/rsyncd.conf`:

```ini
[documents]
path = /volume1/Documents
read only = no
auth users = nate
secrets file = /etc/rsyncd.secrets

[music]
path = /volume1/Music
read only = no
auth users = nate
secrets file = /etc/rsyncd.secrets

[photos]
path = /volume1/Photos
read only = no
auth users = nate
secrets file = /etc/rsyncd.secrets

[audiobooks]
path = /volume1/Audiobooks
read only = no
auth users = nate
secrets file = /etc/rsyncd.secrets
```

## Troubleshooting

### Sync Not Running

Check if timer is active:
```bash
systemctl --user list-timers | grep nas-sync
```

Check service status:
```bash
systemctl --user status nas-sync-documents.service
```

### Connection Issues

Test NAS connectivity:
```bash
~/.local/bin/nas/check-nas-connection
```

Ping the NAS:
```bash
ping 192.168.8.238
```

### Permission Denied

Verify password file exists and has correct permissions:
```bash
ls -l ~/.config/nas-sync/rsync-password
```

Should show: `-rw------- 1 nate nate`

### Files Not Syncing

Check for conflicts in the logs:
```bash
journalctl --user -u nas-sync-documents.service -n 50
```

Manually test the rsync command:
```bash
rsync -avzu --password-file=~/.config/nas-sync/rsync-password \
  ~/Documents/ rsync://nate@192.168.8.238:873/documents/
```

## Files

**Scripts:**
- `~/.local/bin/nas/sync-to-nas` - Main sync script
- `~/.local/bin/nas/sync-documents` - Documents wrapper
- `~/.local/bin/nas/sync-music` - Music wrapper
- `~/.local/bin/nas/sync-photos` - Photos wrapper
- `~/.local/bin/nas/sync-audiobooks` - Audiobooks wrapper
- `~/.local/bin/nas/check-nas-connection` - Connectivity check

**Systemd Units:**
- `~/.config/systemd/user/nas-sync-*.service` - Service definitions
- `~/.config/systemd/user/nas-sync-*.timer` - Timer schedules

**Configuration:**
- `~/.config/nas-sync/rsync-password` - NAS password (600 permissions)

**Dotfiles:**
- Source: `~/dotfiles/home/.local/bin/nas/`
- Source: `~/dotfiles/home/.config/systemd/user/nas-sync-*`
