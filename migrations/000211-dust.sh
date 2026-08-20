# 000211-dust.sh -- dust (pacman / apt)
# Installs: dust
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. dust is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "dust"

if is_debian; then
  # Debian names it du-dust.
  install_apt du-dust
else
  install_pacman dust
fi

ok "dust"
