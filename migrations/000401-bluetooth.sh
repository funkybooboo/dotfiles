# 000401-bluetooth.sh -- bluez + bluez-utils
# Installs: bluez bluez-utils
# Deploys: --
# Enables:  --
# Note: the old tracked /etc/modprobe.d/btusb.conf (content: OPTIONS="-d")
#       was INVALID modprobe syntax -- libkmod logged "ignoring bad line" at
#       every boot and the config did nothing. The original intent
#       ("suppress firmware re-download warnings") is not expressible via
#       modprobe.d: btusb has no firmware-related module parameter (only
#       disable_scofix / force_scofix / enable_autosuspend / reset). The file
#       was removed from the repo on 2026-09-16; this migration deletes any
#       copy a previous run deployed, so the boot-time parse error goes away.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "bluetooth"

install_pacman bluez bluez-utils

# Remove the stale invalid-syntax modprobe config if a previous version of
# this migration deployed it. Idempotent.
if sudo test -e /etc/modprobe.d/btusb.conf; then
    sudo rm -f /etc/modprobe.d/btusb.conf
    ok "removed invalid /etc/modprobe.d/btusb.conf (was causing libkmod parse errors at boot)"
fi