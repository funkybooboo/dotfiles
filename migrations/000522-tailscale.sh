# 000522-tailscale.sh — Tailscale mesh VPN
# Installs: tailscale (via official install script)
# Links:    —
# Enables:  tailscaled
# Note: The interactive 'tailscale up' authentication is deferred to
#       setup-secrets.sh (run after reboot into Hyprland). This migration only
#       installs and enables the daemon.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "tailscale"

if command -v tailscale &>/dev/null; then
  skip "Tailscale already installed ($(tailscale version 2>/dev/null | head -1))"
else
  info "installing Tailscale..."
  curl -fsSL https://tailscale.com/install.sh | sh
  ok "Tailscale installed"
fi

enable_system_service "tailscaled"
