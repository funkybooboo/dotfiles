#!/bin/bash
# Wallpaper watcher: set wallpaper at startup and on monitor add/remove events.
# Runs forever under hypr-wallpaper.service (Restart=always). Reconnects if the
# Hyprland event socket drops (e.g. Hyprland restarts) instead of exiting 0,
# which would leave the service dead under Restart=on-failure.
WALLPAPER_SCRIPT="/home/nate/.config/hypr/set-wallpaper.sh"

socket() {
    printf '%s\n' "/run/user/$(id -u)/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
}

# Set once at startup.
"$WALLPAPER_SCRIPT"

# Reconnect loop: if the socket closes or isn't ready yet, wait and retry.
while true; do
    SOCK="$(socket)"
    [ -S "$SOCK" ] || { sleep 1; continue; }
    # Debounce: docking/undocking fires several monitoradded/removed events
    # in quick succession. Wait for a 1.5s quiet gap, then restart once instead
    # of killall+restart on every single event (which races and flashes).
    socat -U - UNIX-CONNECT:"$SOCK" 2>/dev/null | while read -r line; do
        case "$line" in
            monitoradded\>*|monitorremoved\>*)
                # Drain any further events for 1.5s before acting.
                while read -r -t 1.5 _more; do :; done
                "$WALLPAPER_SCRIPT"
                ;;
        esac
    done
    # socat pipe closed (socket dropped); back off before reconnecting.
    sleep 1
done
