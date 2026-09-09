#!/bin/bash
WALLPAPER="/home/nate/Pictures/wallpapers/yellowstone.jpg"
CONF="/home/nate/.config/hypr/hyprpaper.conf"

# Wait for Hyprland IPC to return valid monitor JSON before writing the conf.
# At graphical-session start the socket may answer before it can emit JSON,
# which previously made `hyprctl monitors -j | jq` fail and silently produce a
# wallpaper-less conf (only preload + splash). Fail closed instead.
MONS=""
for _ in $(seq 1 30); do
    MONS=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null)
    [ -n "$MONS" ] && break
    sleep 0.5
done
if [ -z "$MONS" ]; then
    echo "set-wallpaper: no monitors from hyprctl; leaving $CONF unchanged" >&2
    exit 1
fi

{
    echo "preload = $WALLPAPER"
    while read -r mon; do
        printf 'wallpaper {\n    monitor = %s\n    path = %s\n}\n\n' "$mon" "$WALLPAPER"
    done <<< "$MONS"
    echo "splash = false"
} > "$CONF"

killall hyprpaper 2>/dev/null
sleep 0.5
hyprpaper &>/dev/null & disown
