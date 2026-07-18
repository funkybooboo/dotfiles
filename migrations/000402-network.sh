# 000402-network.sh — network stack: iwd (wifi) + systemd-networkd (IP/DHCP)
# Installs: iwd wireless-regdb openresolv
# Deploys: /etc/systemd/network/{20-ethernet,20-wlan,20-wwan}.network,
#          /etc/conf.d/wireless-regdom,
#          /etc/systemd/system/systemd-networkd-wait-online.service.d/override.conf
# Enables: iwd.service, systemd-networkd.service
#
# This is a pure iwd + systemd-networkd setup — NO NetworkManager. iwd handles
# wifi authentication (WPA/PSK, stored per-SSID in /var/lib/iwd/*.psk, which is
# machine-specific and NOT tracked here — configure your SSIDs with `iwctl`).
# systemd-networkd handles IP configuration via the .network files below, which
# are generic (Match by interface Type, DHCP=yes) and safe to ship.
#
# The .network files were originally written by archinstall; tracking them here
# makes the network setup reproducible and gives networkd-wait-online a
# configured interface to wait on.
#
# IMPORTANT for a fresh install: run `iwctl` to connect to your wifi ONCE after
# this migration (iwd saves the network and auto-connects thereafter):
#   iwctl
#   [iwd]# device list
#   [iwd]# station wlan0 scan
#   [iwd]# station wlan0 connect "YourSSID"
#   (enter passphrase; iwd saves it to /var/lib/iwd/<SSID>.psk)

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "network"

install_pacman iwd wireless-regdb openresolv

# systemd-networkd interface config (DHCP for ethernet / wlan / wwan).
for _netfile in 20-ethernet.network 20-wlan.network 20-wwan.network; do
  deploy_etc_file "$DOTFILES_ROOT_ETC/systemd/network/$_netfile" \
    "/etc/systemd/network/$_netfile" 644
done

# Set the wireless regulatory domain. Without WIRELESS_REGDOM set, the global
# regdom stays at 'country 00' (restricted 5GHz / low tx power) and boot emits
#   cfg80211: Process '/usr/bin/set-wireless-regdom' failed with exit code 1
# Deploy the regdom config (defaults to US — adjust per location).
deploy_etc_file "$DOTFILES_ROOT_ETC/conf.d/wireless-regdom" \
  "/etc/conf.d/wireless-regdom" 644

deploy_etc_file \
  "$DOTFILES_ROOT_ETC/systemd/system/systemd-networkd-wait-online.service.d/override.conf" \
  "/etc/systemd/system/systemd-networkd-wait-online.service.d/override.conf" 644

# The override changes ExecStart, so reload systemd to pick it up
sudo systemctl daemon-reload 2>/dev/null || true

# Enable iwd (wifi auth) and systemd-networkd (IP config). Both are safe to
# start now and essential to start on a fresh install (archinstall may have
# enabled them already, in which case these are idempotent no-ops).
enable_system_service "iwd.service"
enable_system_service "systemd-networkd.service"

warn "configure wifi once with 'iwctl' after this migration (saved networks auto-connect)"
_add_warning "run 'iwctl' to connect to wifi (one-time, then auto-connects)"
