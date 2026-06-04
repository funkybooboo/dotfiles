# 21-tailscale.sh — Tailscale install + authenticate

section "Tailscale"

if command -v tailscale &>/dev/null; then
  skip "Tailscale already installed ($(tailscale version | head -1))"
else
  info "installing Tailscale..."
  if [[ $DRY_RUN -eq 1 ]]; then
    info "would run: curl -fsSL https://tailscale.com/install.sh | sh"
  else
    curl -fsSL https://tailscale.com/install.sh | sh
    ok "Tailscale installed"
  fi
fi

if [[ $DRY_RUN -eq 0 ]]; then
  # Enable and start the daemon
  if systemctl is-enabled --quiet tailscaled 2>/dev/null; then
    skip "tailscaled (already enabled)"
  else
    sudo systemctl enable --now tailscaled
    ok "tailscaled enabled"
  fi

  # Authenticate if not already connected
  if tailscale status &>/dev/null; then
    skip "Tailscale already authenticated and connected"
  else
    info "authenticating with Tailscale..."
    sudo tailscale up --accept-routes
    ok "Tailscale connected"
  fi
fi