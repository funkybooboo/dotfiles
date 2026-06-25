# 000525-nas-sync.sh — NAS rsync sync units + helper scripts + timers
# Installs: — (rsync installed by 000221-rsync)
# Links:    ~/.config/systemd/user/nas-sync-{documents,music,photos,
#             audiobooks,books}.{service,timer},
#           ~/.local/bin/{sync-documents,sync-music,sync-photos,
#             sync-audiobooks,sync-books},
#           ~/.local/lib/{check-nas-connection,sync-to-nas,good-time-to-run}
# Enables:  nas-sync-{documents,music,photos,audiobooks,books}.timer
# Note: The NAS rsync PASSWORD and initial clone are deferred to
#       setup-secrets.sh (need proton-pass login + network). The timers are
#       enabled here so they fire automatically once the password is in place.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "nas sync"

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

# Create the nas-sync config dir (password file is written by setup-secrets.sh)
mkdir -p "$HOME/.config/nas-sync"

# Enable timers
for _module in documents music photos audiobooks books; do
  enable_user_service "nas-sync-${_module}.timer"
done
