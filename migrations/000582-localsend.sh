# 000582-localsend.sh -- localsend (nix flake)
# Nix:     .#localsend
# Links:   --
# Enables: --
# Note: one piece of software = one migration. localsend (cross-platform
#       AirDrop-alternative LAN file sharing) has no Arch official package and
#       AUR is excluded by policy, so the nix flake is the cleanest prebuilt
#       path. Receiving files needs inbound port 53317 (UDP for multicast
#       discovery, TCP for transfer), which the default-deny-incoming policy
#       from 000405 blocks -- so this also allows 53317/tcp+udp through UFW.
#       Sending to other devices works without the rule.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "localsend"

install_nix .#localsend

# Inbound allow for localsend: UDP 53317 (multicast discovery) and TCP 53317
# (receiving files). Checked before adding so re-runs stay quiet; ufw itself
# also no-ops on duplicate rules. If ufw is inactive the rules are still
# recorded and take effect when 000405 activates it.
if sudo ufw status | grep -q '53317'; then
  skip "ufw 53317/tcp+udp (allowed)"
else
  if sudo ufw allow 53317/tcp && sudo ufw allow 53317/udp; then
    ok "ufw allows 53317/tcp+udp (localsend receive)"
  else
    warn "failed to add ufw rules for 53317"
    _add_warning "ufw allow 53317/tcp+udp failed; localsend can send but not receive"
  fi
fi

ok "localsend"
