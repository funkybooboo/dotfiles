#!/bin/bash
WALLPAPER_SCRIPT="/home/nate/.config/hypr/set-wallpaper.sh"
SOCKET="/run/user/$(id -u)/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

"$WALLPAPER_SCRIPT"

socat -U - UNIX-CONNECT:"$SOCKET" 2>/dev/null | while read -r line; do
    case "$line" in
        monitoradded\>*|monitorremoved\>*)
            sleep 1
            "$WALLPAPER_SCRIPT"
            ;;
    esac
done