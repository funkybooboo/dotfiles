# 000227-gum.sh — gum (shell script UI toolkit)
# Installs: gum
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "gum"

install_aur gum
