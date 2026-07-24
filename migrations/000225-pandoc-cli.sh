# 000225-pandoc-cli.sh -- pandoc-cli (pacman)
# Installs: pandoc-cli
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. pandoc-cli is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "pandoc-cli"

install_pacman pandoc-cli

ok "pandoc-cli"
