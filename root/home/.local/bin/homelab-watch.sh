#!/bin/bash
# homelab-watch -- off-cluster fleet watcher -> ntfy (LEAN tier).
# Four check families, all deduped by state files (only CHANGES push):
#   1. node pings        (the 4 x86 nodes -- vanish class)
#   2. scrape targets    (any node/guest exporter down, via prometheus)
#   3. https fronts      (the serve-front bookmarks must answer)
#   4. disk / memory     (< 10% free / < 10% available, via prometheus)
# Fronts are READ FROM THE MANIFESTS (~/Projects/homelab/guests/*.yaml
# via the system python -- the repo is the source of truth; a new
# service with tailnet_serve gets watched on the next cycle).
# Born from framework vanish #3 (2026-11-22); lean tier per the
# 2026-11-23 observability decision (alertmanager is the v4 upgrade).
set -u
STATE="$HOME/.local/state/homelab-watch"
NOTIFY="https://ntfy.tail54538d.ts.net/homelab"
PROM="http://192.168.1.17:9090"
GUESTS="$HOME/Projects/homelab/guests"
SYS_PY="/usr/bin/python3.14"   # mise's python lacks yaml; system has it
mkdir -p "$STATE"

notify() { # priority title message
    curl -s -m 10 -H "Priority: $1" -H "Title: $2" -d "$3" "$NOTIFY" >/dev/null 2>&1 || true
}

# dedup helper: name state -- records + notifies on change
# args: $1 key, $2 new state, $3 priority, $4 title, $5 message
dedup() {
    local f="$STATE/$1" prev
    prev="$(cat "$f" 2>/dev/null || echo unknown)"
    [ "$prev" = "unknown" ] && { echo "$2" > "$f"; return; }   # first sighting silent
    if [ "$2" != "$prev" ]; then
        echo "$2" > "$f"
        notify "$3" "$4" "$5"
    fi
}

# --- 1. node pings
for line in "pve-thermaltake 192.168.1.3" "pve-framework 192.168.1.4" \
            "pve-aspiree15 192.168.1.5" "pve-aspires 192.168.1.6"; do
    name="${line%% *}"; ip="${line##* }"
    if ping -c1 -W3 "$ip" >/dev/null 2>&1; then s=up; else s=down; fi
    dedup "node-$name" "$s" urgent "node $name $s" \
        "$name ${s} (ping). ${s} = check the box."
done

# --- 2. scrape targets (any exporter down)
TARGETS_JSON="$(curl -s -m 10 "$PROM/api/v1/targets" 2>/dev/null || echo '{}')"
mapfile -t TUPLES < <(printf '%s' "$TARGETS_JSON" | "$SYS_PY" -c '
import json,sys
try:
    for t in json.load(sys.stdin)["data"]["activeTargets"]:
        print(t["labels"].get("instance", "?") + " " + t["health"])
except Exception:
    pass')
DOWN_TARGETS=""
for t in "${TUPLES[@]:-}"; do
    [ -z "$t" ] && continue
    if [ "${t##* }" != "up" ]; then DOWN_TARGETS="${DOWN_TARGETS} ${t%% *}"; fi
done
dedup "scrape-targets" "${DOWN_TARGETS:-ok}" high "scrape targets ${DOWN_TARGETS:+down: $DOWN_TARGETS}" \
    "Exporter targets ${DOWN_TARGETS:-ok}. A down exporter = the box or its agent is unhealthy."

# --- 3. https fronts (from the manifests)
if [ -d "$GUESTS" ] && [ -x "$SYS_PY" ]; then
    mapfile -t FRONTS < <("$SYS_PY" -c '
import yaml, glob, os
for f in sorted(glob.glob(os.path.expanduser("'"$GUESTS"'") + "/*.yaml")):
    try:
        d = yaml.safe_load(open(f))
        if d.get("state", "present") == "present" and "tailnet_serve" in d:
            print(d["name"], "https://%s.tail54538d.ts.net" % d["name"])
    except Exception:
        pass' 2>/dev/null)
    for pair in "${FRONTS[@]:-}"; do
        [ -z "$pair" ] && continue
        fname="${pair%% *}"; url="${pair##* }"
        code="$(curl -s -o /dev/null -m 10 -w "%{http_code}" "$url" 2>/dev/null || echo 000)"
        case "$code" in 2*|3*) s=ok ;; *) s="fail-$code" ;; esac
        dedup "front-$fname" "$s" high "front $fname $s" \
            "https front $fname answered $code (was expecting 2xx/3xx)."
    done
fi

# --- 4. disk + memory thresholds (instant queries)
PCT_QUERY() { # promql -> percent int or "err"
    "$SYS_PY" -c "
import json,sys,urllib.request
try:
    r = json.load(urllib.request.urlopen('$PROM/api/v1/query?query=' + urllib.parse.quote('''$1'''), timeout=8))
    v = r['data']['result'][0]['value'][1]
    print(int(float(v)))
except Exception:
    print('err')"
}
DISK="$(PCT_QUERY '100 * (1 - node_filesystem_avail_bytes{fstype!~"tmpfs|overlay|squashfs",mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"})' 2>/dev/null)"
MEM="$(PCT_QUERY '100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)' 2>/dev/null)"
[ "$DISK" != "err" ] && [ "$DISK" -lt 10 ] 2>/dev/null && s="low-$DISK%" || s=ok
dedup "disk-low" "$s" urgent "disk ${DISK}% full" "Root filesystem usage is critical on some node (${DISK}% full)."
[ "$MEM" != "err" ] && [ "$MEM" -gt 90 ] 2>/dev/null && s="high-$MEM%" || s=ok
dedup "mem-high" "$s" high "memory ${MEM}% used" "Memory is above 90% on some node (${MEM}%)."
