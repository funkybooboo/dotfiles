#!/usr/bin/env python3

# Function to convert bytes to a human-readable format
def get_human_readable(bytes):
    if bytes < 1024:
        return f"{bytes}B"
    elif bytes < 1024 * 1024:
        return f"{bytes / 1024:.1f}KB"
    elif bytes < 1024 * 1024 * 1024:
        return f"{bytes / (1024 * 1024):.1f}MB"
    else:
        return f"{bytes / (1024 * 1024 * 1024):.1f}GB"

# Initialize counters for total received and sent bytes
total_received = 0
total_sent = 0

# Read from /proc/net/dev
with open('/proc/net/dev', 'r') as f:
    # Skip the first two lines (header)
    lines = f.readlines()[2:]

    for line in lines:
        # Split the line by spaces, remove leading/trailing spaces, and ignore empty values
        fields = line.split()
        
        # Extract the interface name (remove the colon)
        iface = fields[0].rstrip(':')
        
        # Extract received and sent bytes (columns 1 and 9)
        try:
            rec = int(fields[1])
            sent = int(fields[9])
        except ValueError:
            continue
        
        # Skip interfaces with 0 bytes received or sent
        if rec > 0 or sent > 0:
            total_received += rec
            total_sent += sent

# Get human-readable stats for total received and sent bytes
received_human = get_human_readable(total_received)
sent_human = get_human_readable(total_sent)

# Print the summarized stats in a shorter format
print(f"R: {received_human}, S: {sent_human}")

