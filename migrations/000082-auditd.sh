# 000082-auditd.sh -- Linux audit daemon + hardening rules
# Installs: audit
# Deploys: /etc/audit/rules.d/hardening.rules
# Enables:  auditd.service

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "auditd"

if is_debian; then
  if [[ "${DOTFILES_ENABLE_AUDITD:-0}" == "1" ]]; then
    install_apt auditd
    deploy_etc_file "$DOTFILES_ROOT_ETC/audit/rules.d/hardening.rules" \
      "/etc/audit/rules.d/hardening.rules" 640
    # Load the new audit rules immediately
    if command -v augenrules &>/dev/null; then
      sudo augenrules --load >/dev/null 2>&1 || true
      ok "audit rules loaded"
    fi
    enable_system_service "auditd.service"
  else
    skip "auditd (set DOTFILES_ENABLE_AUDITD=1 to enable on Debian)"
    return 0 2>/dev/null || exit 0
  fi
else
  install_pacman audit

  deploy_etc_file "$DOTFILES_ROOT_ETC/audit/rules.d/hardening.rules" \
    "/etc/audit/rules.d/hardening.rules" 640

  # Load the new audit rules immediately
  if command -v augenrules &>/dev/null; then
    sudo augenrules --load >/dev/null 2>&1 || true
    ok "audit rules loaded"
  fi

  enable_system_service "auditd.service"
fi
