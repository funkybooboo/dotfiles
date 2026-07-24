# 000213-jq.sh -- jq (pacman)
# Installs: jq
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. jq is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "jq"

install_pacman jq

ok "jq"
