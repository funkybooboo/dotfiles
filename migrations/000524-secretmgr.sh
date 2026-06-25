# 000524-secretmgr.sh — secretmgr tool + config
# Installs: — (secretmgr is a personal script in ~/.local/bin)
# Links:    ~/.local/bin/secretmgr, ~/.config/secretmgr/config.toml
# Enables:  —
# Note: 'secretmgr bootstrap' (injects secrets into templated configs) is
#       deferred to setup-secrets.sh — it requires proton-pass login first.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "secretmgr"

link_file "$DOTFILES_HOME/.local/bin/secretmgr"          "$HOME/.local/bin/secretmgr"
link_file "$DOTFILES_HOME/.config/secretmgr/config.toml" "$HOME/.config/secretmgr/config.toml"
