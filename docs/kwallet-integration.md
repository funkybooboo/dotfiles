# KWallet Integration for SSH and GPG

## Overview
Automated passphrase management using KDE Wallet (KWallet) to securely store and retrieve SSH key and GPG passphrases. This eliminates the need to enter passphrases repeatedly while maintaining security through encrypted storage.

## Components

### SSH Integration
- **Systemd Service:** `~/.config/systemd/user/ssh-agent.service`
- **SSH Askpass Tool:** `/usr/bin/ksshaskpass`
- **SSH Socket:** `$XDG_RUNTIME_DIR/ssh-agent.socket` (typically `/run/user/1000/ssh-agent.socket`)
- **Configuration:** `~/.bashrc` (lines 220-236)

### GPG Integration
- **GPG Agent Config:** `~/.gnupg/gpg-agent.conf`
- **Pinentry Program:** `/usr/bin/pinentry-qt`
- **Cache Duration:** 8 hours (default), 12 hours (maximum)

### KWallet
- **Wallet File:** `~/.local/share/kwalletd/kdewallet.kwl`
- **Encryption:** Blowfish
- **Password Manager:** Stores SSH and GPG passphrases securely

## How It Works

### SSH Key Management
1. **Persistent Agent:** A single ssh-agent runs as a systemd user service, shared across all terminals
2. **First Use:** When opening a new terminal, `ksshaskpass` prompts for SSH key passphrase via GUI dialog
3. **KWallet Storage:** Passphrase is stored in KWallet (encrypted)
4. **Subsequent Use:** KWallet provides the passphrase automatically without manual entry
5. **Session Lifetime:** SSH key remains loaded until logout/reboot

### GPG Key Management
1. **Pinentry Qt:** When signing Git commits, `pinentry-qt` displays GUI dialog for GPG passphrase
2. **Cache First:** GPG agent caches the passphrase for 8-12 hours
3. **KWallet Storage:** If "Save in password manager" is checked in pinentry-qt, passphrase is stored in KWallet
4. **Auto-Retrieve:** After cache expires, KWallet auto-provides passphrase without manual entry

## Configuration Files

### SSH Agent Service
**File:** `~/.config/systemd/user/ssh-agent.service`
```ini
[Unit]
Description=SSH key agent

[Service]
Type=simple
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -D -a $SSH_AUTH_SOCK
ExecStartPost=/usr/bin/systemctl --user set-environment SSH_AUTH_SOCK=${SSH_AUTH_SOCK}

[Install]
WantedBy=default.target
```

### Bashrc Configuration
**File:** `~/.bashrc` (lines 220-236)
```bash
# -------------------------------
# SSH agent setup with KWallet integration
# -------------------------------
# Use persistent ssh-agent from systemd service
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Configure SSH to use ksshaskpass for passphrase prompts (integrates with KWallet)
export SSH_ASKPASS="/usr/bin/ksshaskpass"
export SSH_ASKPASS_REQUIRE=prefer

# Add ED25519 key if not already added
if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
  ssh-add -l >/dev/null 2>&1 || {
    # Key not loaded, add it (will use ksshaskpass/KWallet for passphrase)
    ssh-add "$HOME/.ssh/id_ed25519" </dev/null >/dev/null 2>&1
  }
fi
```

### GPG Agent Configuration
**File:** `~/.gnupg/gpg-agent.conf`
```bash
# GPG Agent Configuration

# Cache passphrase for 8 hours (28800 seconds)
default-cache-ttl 28800

# Maximum cache time: 12 hours (43200 seconds)
max-cache-ttl 43200

# Use Qt pinentry (integrates with KWallet)
pinentry-program /usr/bin/pinentry-qt

# Allow terminal-based passphrase entry (no pinentry)
allow-loopback-pinentry
```

## Required Packages
```bash
sudo pacman -S ksshaskpass kwallet pinentry
```

All three packages must be installed for the integration to work properly.

## Service Management

### SSH Agent Service

**Check status:**
```bash
systemctl --user status ssh-agent.service
```

**View logs:**
```bash
journalctl --user -u ssh-agent.service
```

**Restart service:**
```bash
systemctl --user restart ssh-agent.service
```

**Stop service:**
```bash
systemctl --user stop ssh-agent.service
```

**Start service:**
```bash
systemctl --user start ssh-agent.service
```

**Disable on startup:**
```bash
systemctl --user disable ssh-agent.service
```

**Enable on startup:**
```bash
systemctl --user enable ssh-agent.service
```

### Check Loaded SSH Keys
```bash
ssh-add -l
```

### Manually Add SSH Key
```bash
ssh-add ~/.ssh/id_ed25519
```

### Remove All SSH Keys from Agent
```bash
ssh-add -D
```

### GPG Agent Management

**Reload GPG agent:**
```bash
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent
```

**Check GPG agent status:**
```bash
gpg-connect-agent 'keyinfo --list' /bye
```

**Test GPG signing:**
```bash
echo "test" | gpg --sign --armor
```

## First-Time Setup

### SSH Key Passphrase
1. Open a new terminal
2. `ksshaskpass` will display a GUI dialog asking for your SSH key passphrase
3. Enter your passphrase
4. The passphrase is stored in KWallet
5. Future terminals will not prompt for the passphrase

### GPG Key Passphrase
1. Make a Git commit that requires signing
2. `pinentry-qt` will display a GUI dialog asking for your GPG passphrase
3. **Important:** Check the "Save in password manager" checkbox
4. Enter your passphrase
5. The passphrase is cached and stored in KWallet
6. Future commits within 8-12 hours use the cache
7. After cache expires, KWallet auto-provides the passphrase

### KWallet Setup
When KWallet prompts for encryption method:
1. Choose **Blowfish** encryption
2. Create a wallet password (remember it!)
3. The wallet unlocks automatically when needed
4. Wallet remains unlocked until logout/session end

## Testing

### Test SSH Integration
```bash
# Check if ssh-agent is running
systemctl --user status ssh-agent.service

# Check loaded keys
ssh-add -l

# Test SSH connection
ssh -T git@github.com
```

### Test GPG Integration
```bash
# Test GPG signing
echo "test" | gpg --sign --armor

# Test in a Git repo
git commit --allow-empty -m "Test commit" -S
```

### Test KWallet
```bash
# Check KWallet daemon status
ps aux | grep kwalletd

# Query KWallet (requires kwallet-query to be installed)
kwallet-query -l kdewallet
```

## Troubleshooting

### SSH Key Not Loading Automatically

**Check if ssh-agent service is running:**
```bash
systemctl --user status ssh-agent.service
```

**Check SSH_AUTH_SOCK environment variable:**
```bash
echo $SSH_AUTH_SOCK
# Should output: /run/user/1000/ssh-agent.socket
```

**Manually add key to test:**
```bash
ssh-add ~/.ssh/id_ed25519
```

**Check ksshaskpass is installed:**
```bash
which ksshaskpass
# Should output: /usr/bin/ksshaskpass
```

### GPG Passphrase Not Cached

**Check gpg-agent configuration:**
```bash
cat ~/.gnupg/gpg-agent.conf
```

**Reload gpg-agent:**
```bash
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent
```

**Check pinentry program:**
```bash
gpgconf --list-components | grep pinentry
```

### KWallet Not Opening

**Check if kwalletd is running:**
```bash
ps aux | grep kwalletd
```

**Check wallet file exists:**
```bash
ls -la ~/.local/share/kwalletd/
```

**Reset KWallet (WARNING: deletes all stored passwords):**
```bash
rm ~/.local/share/kwalletd/kdewallet.kwl
```

### Passphrase Prompt Still Appears

**For SSH:**
1. Verify `SSH_ASKPASS` is set: `echo $SSH_ASKPASS`
2. Check if key is loaded: `ssh-add -l`
3. Remove and re-add key: `ssh-add -D && ssh-add ~/.ssh/id_ed25519`
4. Ensure KWallet is unlocked

**For GPG:**
1. Verify pinentry-qt is configured: `grep pinentry ~/.gnupg/gpg-agent.conf`
2. Check cache settings: `grep cache ~/.gnupg/gpg-agent.conf`
3. Ensure "Save in password manager" was checked in pinentry-qt
4. Reload agent: `gpgconf --kill gpg-agent`

### Environment Variables Not Set

**Check if .bashrc sources correctly:**
```bash
source ~/.bashrc
echo $SSH_AUTH_SOCK
echo $SSH_ASKPASS
```

**For new terminals, ensure .bashrc is loaded:**
- Check your terminal emulator settings
- Verify bash is running as login shell if needed

## Security Considerations

### SSH Key Security
- SSH private key is encrypted with AES-256-CTR + bcrypt
- Passphrase stored in KWallet (Blowfish encrypted)
- KWallet itself requires a password to unlock
- SSH key remains in memory only while agent is running

### GPG Key Security
- GPG private key stored in `~/.gnupg/` with restricted permissions
- Passphrase cached in memory by gpg-agent (8-12 hours)
- Passphrase stored in KWallet (Blowfish encrypted)
- Cache cleared on logout/session end

### Best Practices
- Use strong KWallet password
- Use strong SSH and GPG key passphrases
- Lock screen when away from computer
- KWallet auto-locks on session end
- SSH agent clears keys on logout
- GPG agent clears cache on logout

## Additional Resources

- [KWallet Documentation](https://userbase.kde.org/KDE_Wallet_Manager)
- [SSH Agent Forwarding](https://wiki.archlinux.org/title/SSH_keys#ssh-agent)
- [GPG Agent Documentation](https://wiki.archlinux.org/title/GnuPG#gpg-agent)
- [Pinentry](https://wiki.archlinux.org/title/GnuPG#pinentry)
