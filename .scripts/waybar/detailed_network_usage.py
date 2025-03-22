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

# Read from /proc/net/dev
with open('/proc/net/dev', 'r') as f:
    # Skip the first two lines (header)
    lines = f.readlines()[2:]

    output = []

    # Loop through each interface
    for line in lines:
        # Split the line by spaces, remove leading/trailing spaces, and ignore empty values
        fields = line.split()
        
        # Extract the interface name (remove the colon)
        iface = fields[0].rstrip(':')
        
        # Extract received and sent bytes (columns 1 and 9)
        try:
            rec = int(fields[1])
            sent = int(fields[9])
            rec_packets = int(fields[2])  # packets received
            sent_packets = int(fields[10])  # packets sent
        except ValueError:
            continue
        
        # Skip interfaces with 0 bytes received or sent
        if rec > 0 or sent > 0:
            output.append(f"{iface}:\n\tR: {get_human_readable(rec):<8} S: {get_human_readable(sent):<8}")
            output.append(f"\tPkts R: {rec_packets:<6} S: {sent_packets:<6}")

    # Print the formatted output
    if output:
        print("\n".join(output))
    else:
        print("No network activity detected.")

