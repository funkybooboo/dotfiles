---
name: proxmox
description: >
  Homelab Proxmox VE cluster reference: node topology and quirks, SSH access patterns,
  CT/VM inventory with web ports, HA rules system, load balancer, static IP scheme,
  media CTs, gcx Grafana CLI. Triggers: proxmox, pve, PVE node, CT, vmid, ha-manager,
  pct, pvesh, corosync, cluster, balancer, homelab, jellyfin, navidrome, freshrss,
  syncstorage, omnivore, audiobookshelf, tailscale serve, gcx, grafana.
---

# Proxmox homelab reference

## Cluster topology (pve-cluster, PVE 8)

- 5 nodes, corosync knet/udp over LAN 192.168.8.0/24, 5 votes. Tailnet:
  tail54538d.ts.net; every node reachable as root@<name>.tail54538d.ts.net.
- **pve-framework** -- Zhaoxin x86; sole uplink is a USB 2.5GbE RTL8156 dongle.
  FLAKY: NIC drops crash-reset the node (corosync loses quorum -> softdog fires).
  Needs a PCIe NIC or powered hub+cable. Excluded as balancer target until fixed;
  expect its CTs to relocate on its own.
- **pve-aspires** -- DC / HA master. **pve-aspiree15**. **pve-thermaltake** --
  the ONLY node with a GPU (jellyfin NVENC etc. live here); load avg 3-12 is its
  steady state, not a problem. **raspberrypi** -- arm64 quorum witness, hosts
  zero guests; runs the pve-balance scheduler; its pve-ha-lrm has been stale/dead
  since 2026-07-26 (should not be an HA placement target; long-term fix or drop
  from HA consideration).

## SSH access (from debbie / agent host)

- `ssh root@pve-<node>` works directly for all 5 nodes (shared agent key
  nate.stott@pm.me). MUST use `root@` -- `nate@` is not authorized on PVE nodes.
  Tailscale SSH does not work on PVE nodes. Agent has no TTY: key-based only.
- `ssh root@truenas` (root SSH enabled ~2026-08-02; `nate@truenas` has no sudo;
  nate = uid 3000). Router: `ssh root@gl-mt2500.tail54538d.ts.net` (OpenWrt).
- Homelab repo (canonical): github.com/funkybooboo/homelab, ~/Projects/homelab.

## Static IP scheme (2026-08-05)

- All real CTs: static `192.168.8.<CTID-80>/24`, gw 192.168.8.1 (CT100 -> .20 ...
  CT134 -> .54; sits below the router DHCP pool .100-.249).
- Apply WITHOUT rebooting: `pct set` + `static-ip-apply.sh` pushed in and run
  via `pct exec` (kills dhcp client, hot-swaps eth0). NEVER rapidly pct-reboot
  HA-managed CTs -- that stressed the LRM and the HA watchdog reset pve-framework
  mid-run.
- Apps that store their own LAN IP (n8n N8N_HOST etc.) need updating after
  renumbering; prefer tailscale MagicDNS names.

## HA rules system

- New rules API (`ha-manager groupconfig` errors with "groups migrated to
  rules"): `ha-manager rules {add,set,remove,config,list}` +
  `pvesh set /cluster/ha/rules/<rule>`.
- ORDER MATTERS: `ha-manager add ct:NNN --state started` FIRST, then append to
  the x86-only node-affinity rule `ha-rule-a5afb54f-b936` (strict=1, the 4 amd64
  nodes; excludes arm64 Pi). Removing a CT from HA drops it from the rule --
  re-append each time.
- ARM64 STRANDING recovery (amd64 CT relocated to raspberrypi -> freeze):
  `ha-manager set ct:NNN --state disabled` + `ha-manager remove`, then
  `mv /etc/pve/nodes/raspberrypi/lxc/NNN.conf -> /etc/pve/nodes/<good>/lxc/`
  (pmxcfs is cluster-replicated; shared NFS rootfs needs no disk copy),
  `pct start`, re-add HA + re-append rule.

## Load balancer (services/pve-balance in the homelab repo)

- Runs on raspberrypi ONLY (1h timer): neutral arbiter (hosts no guests) on the
  most stable node. Cluster-coordination code kept dormant (heartbeat lock +
  shared cooldown in /etc/pve/pve-balance/{lock,state.json}).
- Score = 0.7*load15/cores + 0.3*memused/memtotal; per-arch families (Pi never
  receives amd64 guests); monotone-convergence accept, ONE migration per run;
  3h per-guest cooldown; EXCLUDE_NODES=["pve-framework"] until its NIC is fixed;
  only moves FROM the hottest node (never drains excluded nodes).

## CT inventory (vmid -> name @ node -> web port; HTTPS via `tailscale serve --bg --https 443`)

```
101 alpine-it-tools @ framework | 102 jellyfin @ thermaltake 8096
103 speedtest-tracker @ thermaltake 80 | 104 freshrss @ aspiree15 80
105 forgejo-mirror @ framework 4321 | 106 n8n @ framework 5678
107 forgejo @ aspires 3000 | 108 postgresql @ aspires (no web)
109 vaultwarden @ aspiree15 8000 | 111 adminer @ aspires 80
112 linkwarden @ aspiree15 3000 | 113 opengist @ framework 6157 (+2222 ssh)
118 jupyternotebook @ framework 8888 | 119 searxng @ aspiree15 8888
120 excalidraw @ thermaltake 3000 | 121 drawio @ thermaltake 8080 (/draw/)
122 prometheus @ aspiree15 9090 | 123 grafana @ aspires 3000
124 prometheus-pve-exporter @ framework 9221 (HTTPS breaks scrape unless config updated)
127 cronmaster @ aspiree15 3000 | 128 ntfy @ aspires
131 syncstorage-rs @ thermaltake 8000 | 132 navidrome @ thermaltake 4533
133 audiobookshelf @ thermaltake 13378 | 134 omnivore @ thermaltake (web:3000, api:4000)
```
- Media CTs 131-134 all on pve-thermaltake, HA-managed, x86-only rule, tailscale
  TLS at https://<name>.tail54538d.ts.net. LAN: 131=.190 132=.230 133=.126 134=.185.
- VMs 100/114/115/117 = stopped templates. All CT rootfs on pve-shared NFS
  (shared -> live migration is config-pointer-only, seconds).

## gcx (Grafana 13 unified storage CLI)

- Folders: `gcx resources get folders -o json`; one folder PER FILE (multi-doc
  YAML counts as 1 resource on push). Dashboards:
  `gcx dashboards create -f <file> --api-version dashboard.grafana.app/v1beta1`;
  folder is set via annotation `grafana.app/folder: <slug>uid`, NOT a spec field.
- Dashboards live in ~/Projects/homelab under services/observability/grafana/.
  Config ~/.config/gcx/config.yaml context `local` ->
  http://grafana.tail54538d.ts.net:3000. `gcx dashboards snapshot` needs the
  image-renderer plugin (Grafana CT 123 does not have it -> no PNG snapshots).