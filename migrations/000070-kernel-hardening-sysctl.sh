# 000070-kernel-hardening-sysctl.sh — kernel hardening sysctl parameters
# Installs: —
# Deploys: /etc/sysctl.d/99-hardening.conf
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "Kernel Hardening (sysctl)"

deploy_etc_file "$DOTFILES_ROOT_ETC/sysctl.d/99-hardening.conf" \
  "/etc/sysctl.d/99-hardening.conf" 644

# Apply the new parameters immediately
if command -v sysctl &>/dev/null; then
  sudo sysctl -p /etc/sysctl.d/99-hardening.conf >/dev/null 2>&1 || true
  ok "sysctl parameters applied"
fi
