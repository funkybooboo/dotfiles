# 000212-fastfetch.sh -- fastfetch (pacman)
# Installs: fastfetch
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. fastfetch is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "fastfetch"

install_pacman fastfetch

ok "fastfetch"
