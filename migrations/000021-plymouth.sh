# 000021-plymouth.sh -- Plymouth boot splash
# Installs: plymouth
# Links:    --
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

require_os arch || { return 0 2>/dev/null || exit 0; }

section "Plymouth"

install_pacman plymouth
ok "Plymouth"
