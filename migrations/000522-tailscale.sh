# 000522-tailscale.sh -- Tailscale mesh VPN
# Installs: tailscale (via official install script)
# Links:    --
# Enables:  tailscaled
# Note: The interactive 'tailscale up' authentication is deferred to
#       setup.sh (run after reboot into Hyprland). This migration installs
#       and enables the daemon, and ROLLS IT FORWARD on every migrate run
#       via the built-in `tailscale update` self-updater (2026-11-27
#       roll-forward policy).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "tailscale"

if command -v tailscale &>/dev/null; then
  # Built-in self-updater (downloads the latest stable and swaps the
  # binary; a no-op when already current). Part of the roll-forward
  # policy: every migrate run brings installed software forward.
  if tailscale update --yes >/dev/null 2>&1; then
    ok "tailscale up to date ($(tailscale version 2>/dev/null | head -1))"
  else
    warn "tailscale update failed (non-fatal)"
    _add_warning "tailscale: self-update failed; check 'tailscale update' output"
  fi
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
