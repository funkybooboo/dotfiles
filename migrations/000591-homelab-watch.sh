# 000591-homelab-watch.sh -- off-cluster node-down watcher (-> ntfy)
# Links:    the script + both units, EXPLICITLY (link_file x3 -- the
#           original header claimed a wholesale link_tree covers
#           .local/bin and .config/systemd/user, which does not
#           exist; the units ran only because they were hand-linked
#           during the build session, the script link was never
#           made, and the watcher silently 203/EXEC'd every 5 min
#           for its first 14 hours. Migrations own their links.)
# Enables:   homelab-watch.timer (user), linger for the operator
# Note: born from framework vanish event #3 (2026-11-22): a node
#       died silently; nothing noticed for 40 min until a converge
#       failed. Debbie (always-on, off-cluster) now pings the four
#       x86 nodes every 5 minutes and pushes state CHANGES to the
#       operator's ntfy homelab topic (urgent on down, high on
#       recovery; first sighting silent). NO crontab: debbie runs
#       systemd timers (no cron daemon); the user timer needs
#       lingering so it runs with no login session. The ntfy topic
#       is open (topics are the access control); no secret involved.
#       This is interim OPS-8 wiring -- prometheus alert rules
#       supersede it when OPS-11's alert routing lands.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "homelab watch"

link_file "$DOTFILES_HOME/.local/bin/homelab-watch.sh" \
    "$HOME/.local/bin/homelab-watch.sh"
link_file "$DOTFILES_HOME/.config/systemd/user/homelab-watch.service" \
    "$HOME/.config/systemd/user/homelab-watch.service"
link_file "$DOTFILES_HOME/.config/systemd/user/homelab-watch.timer" \
    "$HOME/.config/systemd/user/homelab-watch.timer"

if ! loginctl show-user "$USER" 2>/dev/null | grep -q "Linger=yes"; then
    if loginctl enable-linger "$USER" 2>/dev/null; then
        ok "user lingering enabled (timer runs without a session)"
    else
        _add_warning "enable-linger failed -- the timer only runs while logged in"
    fi
else
    ok "user lingering already on"
fi

if systemctl --user enable --now homelab-watch.timer 2>/dev/null; then
    ok "homelab-watch.timer enabled (every 5 min)"
else
    _add_error "failed to enable homelab-watch.timer (link_tree ran?)"
fi
