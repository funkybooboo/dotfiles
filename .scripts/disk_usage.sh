#!/usr/bin/env bash

# Set interval (in seconds) and count of reports to display
INTERVAL=1
COUNT=10

# Display header
echo "Disk I/O stats summary:"

# Run iostat to monitor disk I/O
iostat -dx $INTERVAL $COUNT
