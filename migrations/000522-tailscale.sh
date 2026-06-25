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
  _ts_installer=$(mktemp)
  if curl -fsSL https://tailscale.com/install.sh -o "$_ts_installer"; then
    sh "$_ts_installer"
    ok "Tailscale installed"
  else
    warn "failed to download Tailscale installer"
    _add_warning "Tailscale install failed; run the installer manually"
  fi
  rm -f "$_ts_installer"
fi

enable_system_service "tailscaled"
