#!/usr/bin/env bash

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration file next to this script
CONFIG_FILE="$SCRIPT_DIR/break-config.json"

# Check if jq is installed
if ! command -v jq &>/dev/null; then
    echo "Error: jq is required but not installed. Please install jq."
    exit 1
fi

# Verify config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Config file '$CONFIG_FILE' not found."
    exit 1
fi

# Load interval and messages from config
INTERVAL=$(jq '.interval' "$CONFIG_FILE")
mapfile -t MESSAGES < <(jq -r '.breakTypes[]' "$CONFIG_FILE")

TOTAL_MESSAGES=${#MESSAGES[@]}
CURRENT_INDEX=0

# Main loop
while true; do
    MESSAGE="${MESSAGES[CURRENT_INDEX]}"

    # Notify about the upcoming break
    echo "Next break in $INTERVAL minute(s): $MESSAGE"

    # Wait for the interval
    sleep $((INTERVAL * 60))

    # Send desktop notification
    notify-send "Have a break" "$MESSAGE"

    # Move to next message
    CURRENT_INDEX=$(((CURRENT_INDEX + 1) % TOTAL_MESSAGES))
done
