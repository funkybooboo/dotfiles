# 000402-network.sh -- network stack: NetworkManager + iwd wifi backend
# Installs: networkmanager iwd wireless-regdb
# Deploys: /etc/NetworkManager/conf.d/10-iwd-backend.conf,
#          /etc/conf.d/wireless-regdom
# Enables:  NetworkManager.service, NetworkManager-wait-online.service,
#           iwd.service
# Note: WHY NetworkManager. The fleet's wifi manager is impala (000562), a
#       NetworkManager TUI -- it speaks only org.freedesktop.NetworkManager and
#       cannot manage anything else. The previous shape of this migration was
#       raw iwd + systemd-networkd, which worked, but left impala with nothing
#       to talk to (the manager UI could open and never manage) and iwctl as
#       the only option. NetworkManager is therefore the manager here; iwd
#       stays the wifi daemon via wifi.backend=iwd.
# Note: THE BACKEND KEEPS SAVED NETWORKS. Networks live in /var/lib/iwd/*.psk
#       (machine-specific, never tracked here); with iwd as the backend those
#       keep connecting across the switch with no re-entry. New networks are
#       joined through impala, which lands them in the same store.
# Note: DNS stays with systemd-resolved (enabled at install, and
#       /etc/resolv.conf points at its stub). The NM conf pins
#       dns=systemd-resolved so NetworkManager, tailscale's CorpDNS and
#       everything else agree on one resolver instead of racing to rewrite
#       /etc/resolv.conf.
# Note: NETWORKD IS RETIRED HERE. This migration used to deploy
#       /etc/systemd/network/{20-ethernet,20-wlan,20-wwan}.network and a
#       networkd-wait-online override; NetworkManager replaces networkd's
#       role, and leaving both enabled makes two daemons fight over the same
#       interfaces. The files are removed (remove_etc_file) and the services
#       disabled -- networkd goes down BEFORE NM comes up, so a machine
#       converges through a seconds-long blip, not an outage: iwd keeps the
#       wifi association, only the DHCP lease changes hands. Run this at the
#       console on a machine reachable only over SSH/wifi.
# Note: BOOT WAIT-ONLINE. mnt-truenas-nate.mount Wants=network-online.target,
#       so a wait-online service must reach it or the NAS mount stalls at boot.
#       NetworkManager-wait-online replaces networkd-wait-online; it waits for
#       NM-managed devices, and tailscale0 is unmanaged by NM, so the old
#       setup.sh hack that spliced tailscale0 into the networkd wait is dead
#       with this stack and is gone from setup.sh. Nothing on the fleet needs
#       the VPN up before network-online; the NAS needs the wifi, which is what
#       NM waits for.
# Note: on a fresh install, configure wifi once with `impala` after this
#       migration (saved networks auto-connect thereafter).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "network"

install_pacman networkmanager iwd wireless-regdb

# The backend choice must exist before NM's first start, or NM comes up on its
# wpa_supplicant default against a running iwd.
deploy_etc_file "$DOTFILES_ROOT_ETC/NetworkManager/conf.d/10-iwd-backend.conf" \
  "/etc/NetworkManager/conf.d/10-iwd-backend.conf" 644

# Wireless regulatory domain (US default): a kernel-level setting, read by
# set-wireless-regdom at boot regardless of which daemon owns the wifi. Without
# it the regdom stays at the restricted 'country 00'.
deploy_etc_file "$DOTFILES_ROOT_ETC/conf.d/wireless-regdom" \
  "/etc/conf.d/wireless-regdom" 644

# networkd goes down first: it releases the interfaces so NM can take them
# over cleanly in the next step.
disable_system_service "systemd-networkd-wait-online.service"
disable_system_service "systemd-networkd.service"

# The .service disable alone is not enough: networkd's socket units re-trigger
# it after it is disabled. On the first live run (2026-09-17) NM's DNS change
# poked resolved, the resolve-hook socket fired, and networkd was running
# again 90 seconds later -- disabled, preset-enabled sockets and all. Stop and
# disable every socket the service can be triggered by.
disable_system_service "systemd-networkd.socket"
disable_system_service "systemd-networkd-varlink.socket"
disable_system_service "systemd-networkd-varlink-metrics.socket"
disable_system_service "systemd-networkd-resolve-hook.socket"

# iwd first (NM's wifi daemon; already enabled on converged machines), then
# NetworkManager against the deployed conf.
enable_system_service "iwd.service"
enable_system_service "NetworkManager.service"

# mnt-truenas-nate.mount Wants=network-online.target: NM-wait-online is what
# reaches it under this stack (see header note).
enable_system_service "NetworkManager-wait-online.service"

# Retire the networkd config this migration used to deploy. After the service
# is down the files are inert, but leaving them is dead config that contradicts
# this header on every future run.
remove_etc_file "/etc/systemd/network/20-ethernet.network"
remove_etc_file "/etc/systemd/network/20-wlan.network"
remove_etc_file "/etc/systemd/network/20-wwan.network"
remove_etc_file "/etc/systemd/system/systemd-networkd-wait-online.service.d/override.conf"

ok "network (NetworkManager + iwd backend; manage with impala)"