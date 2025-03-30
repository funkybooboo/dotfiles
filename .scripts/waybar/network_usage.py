#!/usr/bin/env python3
import time

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

def read_network_bytes():
    total_received = 0
    total_sent = 0
    with open('/proc/net/dev', 'r') as f:
        # Skip the first two lines (header)
        lines = f.readlines()[2:]
        for line in lines:
            fields = line.split()
            try:
                rec = int(fields[1])
                sent = int(fields[9])
            except ValueError:
                continue
            total_received += rec
            total_sent += sent
    return total_received, total_sent

# Initial reading
prev_received, prev_sent = read_network_bytes()

while True:
    time.sleep(60)  # wait for 60 seconds
    curr_received, curr_sent = read_network_bytes()
    
    # Compute the difference
    diff_received = curr_received - prev_received
    diff_sent = curr_sent - prev_sent

    # Convert to human-readable formats
    received_human = get_human_readable(diff_received)
    sent_human = get_human_readable(diff_sent)
    
    # Print the usage during the last minute
    print(f"R: {received_human}, S: {sent_human}")
    
    # Update previous values for the next iteration
    prev_received, prev_sent = curr_received, curr_sent

