# 000239-presenterm.sh -- presenterm (terminal slideshow tool)
# Installs: presenterm
# Links:   --
# Enables: --
# Note: one piece of software = one migration. extra/presenterm carries the same
#       0.16.1 the work repo pulls from nixpkgs, so tier 1 serves it here and the
#       two machines end up on the same version by different routes.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "presenterm"

install_pacman presenterm

ok "presenterm"
