#!/usr/bin/env bash

# debbie-local.sh — manage debbie-local WireGuard VPN

VPN="debbie-local"

function status() {
    echo "=== VPN Status ==="
    nmcli connection show --active | grep "$VPN" >/dev/null && echo "$VPN is UP" || echo "$VPN is DOWN"
    ip addr show dev "$VPN" 2>/dev/null
    ip route | grep "$VPN"
}

function up() {
    echo "Bringing up $VPN..."
    nmcli connection up "$VPN"
}

function down() {
    echo "Bringing down $VPN..."
    nmcli connection down "$VPN"
}

function toggle_autoconnect() {
    local current
    current=$(nmcli -g connection.autoconnect connection show "$VPN")
    if [ "$current" = "yes" ]; then
        nmcli connection modify "$VPN" connection.autoconnect no
        echo "Auto-connect disabled"
    else
        nmcli connection modify "$VPN" connection.autoconnect yes
        echo "Auto-connect enabled"
    fi
}

function usage() {
    echo "Usage: $0 {up|down|status|autoconnect}"
    exit 1
}

# Main
case "$1" in
    up) up ;;
    down) down ;;
    status) status ;;
    autoconnect) toggle_autoconnect ;;
    *) usage ;;
esac

