#!/bin/sh
# static-ip-apply.sh -- apply a staged static IP to a RUNNING CT WITHOUT reboot.
# Run INSIDE the target CT (via pct exec). Kills any DHCP client, swaps eth0's
# IPv4 to $1/$2-prefix, restores default route. The in-container network config
# (ifupdown / systemd-networkd) must already be set to static by `pct set`.
# Tailscale (tailscale0) survives the sub-second eth0 IP swap.
#
# usage: static-ip-apply.sh <ip-addr/prefix> <gateway>
set -u
IP=$1; GW=$2

# stop any DHCP client that might re-assert the old lease
pkill -x dhclient 2>/dev/null
pkill -x dhcpcd 2>/dev/null
# systemd-networkd: it will pick up the static .network file on restart below
if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1; then
  if systemctl list-unit-files 2>/dev/null | grep -q systemd-networkd; then
    systemctl restart systemd-networkd 2>/dev/null && sleep 1
  fi
  if command -v ifreload >/dev/null 2>&1; then ifreload -a 2>/dev/null; fi
fi

# hot-swap the IPv4 address + default route atomically
ip -4 addr flush dev eth0
ip -4 addr add "$IP" dev eth0
ip route replace default via "$GW" dev eth0 2>/dev/null || ip route add default via "$GW" dev eth0

echo "applied: eth0=$IP gw=$GW"
ip -4 addr show eth0 | grep inet
ip route | grep default