# 000521-globalprotect.sh -- GlobalProtect OpenConnect VPN client
# Installs: globalprotect-openconnect-git
# Links:    --
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "globalprotect"

if is_debian; then
  # yuezk PPA for globalprotect-openconnect is expected to be configured already
  # (see repo third-party PPA setup).
  install_apt globalprotect-openconnect
else
  install_aur globalprotect-openconnect-git
fi
