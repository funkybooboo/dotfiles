# 000217-tealdeer.sh -- tealdeer (pacman / apt)
# Installs: tealdeer
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. tealdeer is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "tealdeer"

if is_debian; then
  install_apt tealdeer
else
  install_pacman tealdeer
fi

ok "tealdeer"
