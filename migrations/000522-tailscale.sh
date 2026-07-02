# 000522-tailscale.sh -- Tailscale mesh VPN
# Installs: tailscale (via official install script)
# Links:    --
# Enables:  tailscaled
# Note: The interactive 'tailscale up' authentication is deferred to
#       setup.sh (run after reboot into Hyprland). This migration only
#       installs and enables the daemon.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "tailscale"

install_via_script tailscale https://tailscale.com/install.sh tailscale

enable_system_service "tailscaled"
