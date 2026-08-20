# 000525-nas-sync.sh -- TrueNAS SMB sync units + helper scripts + timers
# Installs: -- (rsync installed by 000221-rsync, cifs-utils by 000232-smb)
# Deploys: /etc/systemd/system/mnt-truenas-nate.{mount,automount}
# Links:    ~/.config/systemd/user/nas-sync-{documents,music,photos,
#             audiobooks,books}.{service,timer},
#           ~/.local/bin/{sync-documents,sync-music,sync-photos,
#             sync-audiobooks,sync-books},
#           ~/.local/lib/{check-nas-connection,sync-to-nas,good-time-to-run}
# Enables:  nas-sync-{documents,music,photos,audiobooks,books}.timer (user),
#           mnt-truenas-nate.automount (system) -- mounts //truenas/nate at
#           /mnt/truenas/nate on first access (cifs, uid/gid 1000).
# Note: The SMB credentials file ~/.config/nas-sync/smb-creds and the initial
#       seed sync are deferred to setup.sh (need proton-pass login + network).
#       The timers + automount are enabled here so they fire automatically
#       once the creds are in place. rsync cannot speak SMB, so the sync runs
#       local-to-local against the CIFS mount, not over an rsync:// URL.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "nas sync (TrueNAS SMB)"

# --- System-level CIFS automount -------------------------------------------------
# Drop dir for the mount point (systemd creates the leaf on mount, but the
# parent must exist). Idempotent.
sudo mkdir -p /mnt/truenas

# Deploy the .mount + .automount units (see root/etc/systemd/system/).
deploy_etc_file \
  "$DOTFILES_ROOT_ETC/systemd/system/mnt-truenas-nate.mount" \
  "/etc/systemd/system/mnt-truenas-nate.mount" \
  644
deploy_etc_file \
  "$DOTFILES_ROOT_ETC/systemd/system/mnt-truenas-nate.automount" \
  "/etc/systemd/system/mnt-truenas-nate.automount" \
  644

# Arm the automount (enable + start the .automount; the .mount is pulled in on
# first access, NOT enabled directly). Backup-only, idempotent on re-run.
enable_system_service "mnt-truenas-nate.automount"

# --- User-level sync units + scripts + timers ------------------------------------
# User services + timers
for _module in documents music photos audiobooks books; do
  link_file "$DOTFILES_HOME/.config/systemd/user/nas-sync-${_module}.service" \
    "$HOME/.config/systemd/user/nas-sync-${_module}.service"
  link_file "$DOTFILES_HOME/.config/systemd/user/nas-sync-${_module}.timer" \
    "$HOME/.config/systemd/user/nas-sync-${_module}.timer"
done

# Sync wrapper scripts (ExecStart of the services)
for _script in sync-documents sync-music sync-photos sync-audiobooks sync-books; do
  link_file "$DOTFILES_HOME/.local/bin/$_script" "$HOME/.local/bin/$_script"
done

# Shared helpers used by the sync scripts
for _lib in check-nas-connection sync-to-nas good-time-to-run; do
  link_file "$DOTFILES_HOME/.local/lib/$_lib" "$HOME/.local/lib/$_lib"
done

# Create the nas-sync config dir (password file is written by setup.sh)
mkdir -p "$HOME/.config/nas-sync"

# Enable timers
for _module in documents music photos audiobooks books; do
  enable_user_service "nas-sync-${_module}.timer"
done
