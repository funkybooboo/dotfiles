# 000407-filesystem-tools.sh -- DOS/exFAT filesystem utilities
# Installs: dosfstools exfatprogs
# Links:    --
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "filesystem tools"

if is_debian; then
  install_apt dosfstools exfatprogs
else
  install_pacman dosfstools exfatprogs
fi
