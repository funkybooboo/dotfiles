# Install

Covers the quick-start flow, a from-scratch archinstall, and what to back up before wiping a machine.

## Quick start

```bash
git clone --recurse-submodules git@github.com:funkybooboo/dotfiles.git ~/dotfiles
cd ~/dotfiles
./migrate.sh              # install + configure everything
./migrate.sh --firmware   # also apply device firmware (fwupd); may reboot
# reboot into Hyprland
./setup.sh                # secrets, repos, NAS sync, project clone
```

## Fresh install (archinstall)

### Disk layout

| Mount | Size | Type | Encryption |
|-------|------|------|------------|
| `/boot` | 1 GiB | FAT32 | none |
| `/` | rest | btrfs | LUKS |

Btrfs subvolumes: `@` -> `/`, `@home` -> `/home`, `@log` -> `/var/log`,
`@pkg` -> `/var/cache/pacman/pkg`.

### archinstall options

- **Disk encryption:** YES
- **Filesystem:** btrfs, `zstd`
- **Bootloader:** Limine (or systemd-boot, then migrate to Limine)
- **Kernels:** `linux-lts` + `linux-hardened` (or just `linux-lts`)
- **Swap:** zram
- **User:** `nate`, sudo, **shell = bash** (migration sets fish later)
- **Profile:** minimal (not Hyprland -- migration owns it)
- **Network:** NetworkManager (migration 000402 pins the iwd wifi backend; impala manages)
- **Audio:** pipewire (migration installs it anyway)
- **Locale:** `en_US.UTF-8`

### Verify encryption before rebooting

```bash
cryptsetup luksDump /dev/nvme0n1p2
grep '^HOOKS' /etc/mkinitcpio.conf        # must contain 'encrypt'
grep cryptdevice /boot/limine/limine.conf  # must have cryptdevice=...:root
```

`/etc/crypttab` is not required for root encryption -- the initramfs `encrypt`
hook unlocks root via `cryptdevice=` in the kernel cmdline. `migrate.sh`
enforces these checks; override with `DOTFILES_ALLOW_UNENCRYPTED=1` if needed.

### Reboot checklist

- [ ] `systemctl is-enabled ufw greetd apparmor` -- all `enabled`
- [ ] `sudo grep apparmor=1 /boot/limine/limine.conf` -- both kernels
- [ ] `./setup.sh` (after reboot)

After reboot:

```bash
systemctl is-active apparmor
sudo aa-status | head
```

## Back up before wiping

Not recoverable from dotfiles / NAS / Proton Pass:

| Item | Backup command |
|------|---------------|
| GPG secret key | `gpg --export-secret-keys --armor > gpg.asc` |
| GPG ownertrust | `gpg --export-ownertrust > ownertrust.txt` |
| Browser profiles | Browser sync, or copy `~/.librewolf` / `~/.config/brave` |
| Atuin history | `atuin sync` (cloud), or copy `~/.local/share/atuin` |
| pi sessions | `~/.pi/agent/sessions/` |

SSH keys are in Proton Pass `SSH` vault; `secretmgr ssh-add` reloads them
after a fresh install.

