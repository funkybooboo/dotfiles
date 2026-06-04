#!/bin/bash
WALLPAPER="/home/nate/Pictures/wallpapers/yellowstone.jpg"
CONF="/home/nate/.config/hypr/hyprpaper.conf"

{
    echo "preload = $WALLPAPER"
    hyprctl monitors -j | jq -r '.[].name' | while read -r mon; do
        printf 'wallpaper {\n    monitor = %s\n    path = %s\n}\n\n' "$mon" "$WALLPAPER"
    done
    echo "splash = false"
} > "$CONF"

killall hyprpaper 2>/dev/null
sleep 0.5
hyprpaper &>/dev/null & disown