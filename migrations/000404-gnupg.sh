# 000404-gnupg.sh — GnuPG + pinentry + config
# Installs: gnupg pinentry
# Links:    ~/.gnupg/common.conf, ~/.gnupg/gpg.conf, ~/.gnupg/gpg-agent.conf
# Enables:  —
# Note: pinentry-qt is referenced by gpg-agent.conf; pinentry is the meta-package
#       that provides it. chmod 700 ~/.gnupg is applied after configs are linked.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "gnupg"

install_pacman gnupg pinentry

mkdir -p "$HOME/.gnupg"
link_file "$DOTFILES_HOME/.gnupg/common.conf"      "$HOME/.gnupg/common.conf"
link_file "$DOTFILES_HOME/.gnupg/gpg.conf"          "$HOME/.gnupg/gpg.conf"
link_file "$DOTFILES_HOME/.gnupg/gpg-agent.conf"    "$HOME/.gnupg/gpg-agent.conf"
chmod 700 "$HOME/.gnupg"
ok "~/.gnupg → 700"
