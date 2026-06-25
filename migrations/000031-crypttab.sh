# 000031-crypttab.sh — deploy /etc/crypttab (machine-specific)
# Installs: —
# Deploys: /etc/crypttab
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "crypttab"

deploy_etc_file "$DOTFILES_ROOT_ETC/crypttab" "/etc/crypttab" 600
