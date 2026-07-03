# 000405-firewall.sh — UFW firewall + ufw-docker
# Installs: ufw ufw-docker
# Links:    —
# Enables:  ufw.service (started)
# Note: This is a laptop with no inbound SSH requirement, so we apply a basic
#       default-deny-incoming / default-allow-outgoing policy and activate UFW
#       immediately (--force skips the interactive "this may disrupt existing
#       connections" prompt). If you ever expose a service (SSH, web, etc.),
#       add an allow rule BEFORE re-running this migration or before reboot:
#
#         sudo ufw allow ssh   # or: sudo ufw allow 22/tcp

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "firewall"

install_pacman ufw
# ufw-docker: install the upstream shell script via a local PKGBUILD (no AUR).
install_local_pkgbuild ufw-docker

# Base policy: deny inbound, allow outbound. Idempotent — ufw no-ops if the
# policy is already set. Applied before `ufw enable` so the first activation
# has a safe policy in place.
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Activate UFW now. --force skips the interactive confirmation prompt. On a
# laptop with no inbound services this is safe and avoids leaving the machine
# in a half-configured "enabled but not started" state across a reboot.
if sudo ufw status verbose 2>/dev/null | grep -qi '^Status: active'; then
  skip "ufw (already active)"
else
  if sudo ufw --force enable; then
    ok "ufw activated (default deny incoming / allow outgoing)"
  else
    warn "failed to activate ufw — run 'sudo ufw enable' manually"
    _add_warning "ufw --force enable failed; run 'sudo ufw enable' manually"
  fi
fi

# Enable + start the systemd unit so the firewall persists across reboots and
# is running now. Safe to start immediately: the policy above is already live.
enable_system_service "ufw.service"
