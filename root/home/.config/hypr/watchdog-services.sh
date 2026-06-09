#!/bin/bash
# Watchdog: stop daemon if UI process dies
DAEMON_NAME="$1"
UI_CMD="$2"
UI_PID=""

# Find the UI process PID
find_ui_pid() {
    pgrep -f "$UI_CMD"
}

case "$1" in
    opensnitch)
        # Start opensnitchd if not running
        if ! systemctl is-active --quiet opensnitchd; then
            sudo systemctl start opensnitchd
        fi
        # Wait for UI to appear
        while true; do
            UI_PID=$(find_ui_pid "opensnitch-ui")
            if [ -n "$UI_PID" ]; then
                break
            fi
            sleep 1
        done
        # Monitor UI process
        while kill -0 "$UI_PID" 2>/dev/null; do
            sleep 2
        done
        sudo systemctl stop opensnitchd
        ;;
    usbguard)
        # Start usbguard if not running
        if ! systemctl is-active --quiet usbguard; then
            sudo systemctl start usbguard
        fi
        while true; do
            UI_PID=$(find_ui_pid "usbguard-qt")
            if [ -n "$UI_PID" ]; then
                break
            fi
            sleep 1
        done
        while kill -0 "$UI_PID" 2>/dev/null; do
            sleep 2
        done
        sudo systemctl stop usbguard
        ;;
esac