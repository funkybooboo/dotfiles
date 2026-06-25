# 000544-lazyjournal.sh — lazyjournal (TUI git journal)
# Installs: lazyjournal-bin
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "lazyjournal"

install_aur lazyjournal-bin
