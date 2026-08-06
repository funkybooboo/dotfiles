#!/bin/bash
# static-ip-migrate.sh -- convert Proxmox LXC CTs from ip=dhcp to deterministic
#                         STATIC IPv4 addresses so the homelab does not depend
#                         on (unreliable) DHCP lease renewal.
#
# WHY: every CT shipped net0 ip=dhcp; leases expire (router gl-mt2500 sets 12h)
# and the in-CT dhclient/systemd-networkd does not reliably re-acquire, so CTs
# silently lose their LAN IP -> tailscale dies -> the service vanishes. Turning
# off the rogue TP-Link RE315 DHCP server only fixed the IP-conflict half; the
# lease-churn half is fixed here by going fully static.
#
# SCHEME: 192.168.8.<CTID-80>/24 , gateway 192.168.8.1
#   CT100 -> .20, CT101 -> .21 ... CT130 -> .50 ... CT134 -> .54.
# The resulting range .20-.54 sits BELOW the router DHCP pool
# (gl-mt2500 dnsmasq: start=100 limit=150 => .100-.249) and below the pve node
# IPs (.102/.117/.129/.243) and all router static host reservations, so there
# are zero collisions. CT130 was previously static .130 (INSIDE the DHCP pool,
# unreserved -> latent collision risk) and is deliberately moved to .50.
#
# Proxmox auto-rewrites the in-container network config when net0 is set via
# `pct set` (Debian/Alpine ifupdown /etc/network/interfaces get an `inet static`
# stanza; Ubuntu cloud images get a [Network] Address=/Gateway= in
# /etc/systemd/network/eth0.network). A `pct reboot` then applies it cleanly.
#
# USAGE:
#   ./static-ip-migrate.sh <ctid> [<ctid> ...]   # stage conf + reboot if running
#   ./static-ip-migrate.sh --stage-only <ctid>.. # stage conf, do not reboot
#
# Run ON a pve node (uses pct locally). Operate on one node at a time; rebooting
# CTs is ~10-15s each and their tailscale 100.x addresses are eth0-IP-agnostic, so
# MagicDNS names and clients-survive the ~10s eth0 flap.
#
# NOT a dotfiles migration: Proxmox host configs (/etc/pve/lxc/*.conf) are not
# declaratively managed by ~/dotfiles (that repo is for the Arch workstation).
# This script is tracked here only for reproducibility / a systems runbook.
#
# Idempotent: pct set rewrites net0 to the same static value; re-running on an
# already-static CT is a no-op (it will still reboot if running -- pass
# --stage-only to skip the reboot).
# Non-fatal: a single CT failing is printed and skipped, does not abort the run.

set -u

APPLY=1
if [ "${1:-}" = "--stage-only" ]; then APPLY=0; shift; fi

GW=192.168.8.1
NET=192.168.8.0/24
rc=0

migrate() {
  local id=$1
  local cur hwaddr bridge newip
  cur=$(pct config "$id" 2>/dev/null | awk -F'[: ]' '/^net0:/{print $0}')
  if [ -z "$cur" ]; then echo "CT$id: no net0 / not found -- SKIP"; rc=1; return; fi
  hwaddr=$(printf '%s' "$cur" | sed -n 's/.*hwaddr=\([0-9A-Fa-f:]*\).*/\1/p' | tr 'a-f' 'A-F')
  bridge=$(printf '%s' "$cur" | sed -n 's/.*bridge=\([^,]*\).*/\1/p')
  [ -z "$bridge" ] && bridge=vmbr0
  newip="192.168.8.$((id-80))"

  local newnet0="name=eth0,bridge=${bridge},gw=${GW},hwaddr=${hwaddr},ip=${newip}/24,type=veth"

  if pct set "$id" -net0 "$newnet0" 2>/tmp/ctset.err; then
    echo "CT$id: net0 -> static ${newip}/24 gw=${GW} OK"
  else
    echo "CT$id: pct set FAILED: $(cat /tmp/ctset.err) -- SKIP"; rc=1; return
  fi

  local st; st=$(pct status "$id" 2>/dev/null | awk '{print $2}')
  if [ "$APPLY" = "1" ] && [ "$st" = "running" ]; then
    if pct reboot "$id" 2>/tmp/reb.err; then
      # wait for it to come back with the new IP
      local i got=""
      for i in $(seq 1 20); do
        sleep 2
        got=$(pct exec "$id" -- ip -4 addr show eth0 2>/dev/null | sed -n 's/.*inet \([0-9.]*\).*/\1/p' | head -1)
        [ "$got" = "$newip" ] && break
      done
      if [ "$got" = "$newip" ]; then
        local ts; ts=$(pct exec "$id" -- tailscale ip 2>/dev/null | head -1)
        echo "CT$id: rebooted OK ip=${got} tailscale=${ts:-?}"
      else
        echo "CT$id: WARN did not settle to ${newip} (got '${got:-none}') -- inspect"; rc=1
      fi
    else
      echo "CT$id: reboot FAILED: $(cat /tmp/reb.err) -- inspect"; rc=1
    fi
  elif [ "$st" = "stopped" ]; then
    echo "CT$id: stopped -- conf staged, applies on next start"
  fi
}

if [ $# -eq 0 ]; then
  echo "usage: $0 [--stage-only] <ctid> [<ctid>...]" >&2; exit 2
fi
for id in "$@"; do migrate "$id"; done
exit $rc