# 000216-tree.sh -- tree (pacman)
# Installs: tree
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. tree is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "tree"

install_pacman tree

ok "tree"
