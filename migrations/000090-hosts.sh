# 000090-hosts.sh — deploy /etc/hosts (machine-specific)
# Installs: —
# Deploys: /etc/hosts
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "hosts"

deploy_etc_file "$DOTFILES_ROOT_ETC/hosts" "/etc/hosts" 644
