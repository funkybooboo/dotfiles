#!/bin/bash
# homelab-watch -- off-cluster node reachability watcher -> ntfy.
# Born from the framework vanish event #3 (2026-11-22 21:14): a node
# died silently and nothing noticed until a converge tripped over it.
# Debbie watches (she is always-on and off-cluster, so she can see
# the whole cluster fail). State changes push to the ntfy homelab
# topic; the first sighting is recorded silently (no noise on boot).
set -u
STATE="$HOME/.local/state/homelab-watch"
NOTIFY="https://ntfy.tail54538d.ts.net/homelab"
mkdir -p "$STATE"

# name:ip -- the four x86 nodes (the Pi is the quorum witness; truenas
# is appliance-grade with its own alerts class; guests are covered by
# prometheus when OPS-11's alert wiring lands)
NODES="pve-thermaltake:192.168.1.3
pve-framework:192.168.1.4
pve-aspiree15:192.168.1.5
pve-aspires:192.168.1.6"

for line in $NODES; do
    name="${line%%:*}"
    ip="${line##*:}"
    f="$STATE/$name"
    if ping -c1 -W3 "$ip" >/dev/null 2>&1; then
        state=up
    else
        state=down
    fi
    prev="$(cat "$f" 2>/dev/null || echo unknown)"

    if [ "$prev" = "unknown" ]; then
        # first sighting: record silently
        echo "$state" > "$f"
        continue
    fi
    if [ "$state" != "$prev" ]; then
        echo "$state" > "$f"
        title="node $name is $state"
        if [ "$state" = "down" ]; then
            priority=urgent
            msg="$name stopped answering pings (was: $prev). Check the physical box."
        else
            priority=high
            msg="$name answers again (was: $prev)."
        fi
        curl -s -m 10 -H "Priority: $priority" -H "Title: $title" \
            -d "$msg" "$NOTIFY" >/dev/null 2>&1 || true
    fi
done
