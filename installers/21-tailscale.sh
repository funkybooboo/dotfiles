# 21-tailscale.sh — Tailscale install + authenticate

section "Tailscale"

# Install Tailscale
if command -v tailscale &>/dev/null; then
  skip "Tailscale already installed ($(tailscale version 2>/dev/null | head -1))"
elif [[ $DRY_RUN -eq 1 ]]; then
  info "would install: tailscale"
else
  info "installing Tailscale..."
  curl -fsSL https://tailscale.com/install.sh | sh
  ok "Tailscale installed"
fi

if [[ $DRY_RUN -eq 1 ]]; then
  info "would enable: tailscaled"
  info "would authenticate with Tailscale if not connected"
else
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
    info "Tailscale login required — opening browser for authentication..."
    echo -e "  ${DIM}After completing login in the browser, press Enter to continue.${NC}"
    sudo tailscale up --accept-routes
    ok "Tailscale connected"
  fi
fi