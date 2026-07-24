# 000222-ast-grep.sh -- ast-grep (pacman)
# Installs: ast-grep
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. ast-grep is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "ast-grep"

install_pacman ast-grep

ok "ast-grep"
