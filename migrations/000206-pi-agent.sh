# 000206-pi-agent.sh — pi coding agent config (pi installed out-of-band via curl)
# Installs: — (pi is installed separately via the official curl installer)
# Links:    ~/.pi/**
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "pi agent"

link_tree "$DOTFILES_HOME/.pi" "$HOME/.pi"
