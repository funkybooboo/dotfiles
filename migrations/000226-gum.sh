# 000226-gum.sh -- gum (pacman)
# Installs: gum
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. gum is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "gum"

install_pacman gum

ok "gum"
