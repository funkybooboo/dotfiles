# 000082-auditd.sh — Linux audit daemon + hardening rules
# Installs: audit
# Deploys: /etc/audit/rules.d/hardening.rules
# Enables:  auditd.service

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "auditd"

install_pacman audit

deploy_etc_file "$DOTFILES_ROOT_ETC/audit/rules.d/hardening.rules" \
  "/etc/audit/rules.d/hardening.rules" 640

# Load the new audit rules immediately
if command -v augenrules &>/dev/null; then
  sudo augenrules --load >/dev/null 2>&1 || true
  ok "audit rules loaded"
fi

enable_system_service "auditd.service"
