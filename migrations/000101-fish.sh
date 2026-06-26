# 000101-fish.sh — fish shell + config + functions + login shell
# Installs: fish
# Links:    ~/.config/fish/**
# Enables:  —
# Sets:     login shell to /usr/bin/fish (chsh)
#
# chsh requires /usr/bin/fish to be listed in /etc/shells. The fish package
# ships a pacman hook that appends it on install, but we guard explicitly:
# if fish isn't in /etc/shells we append it before chsh so the change never
# fails. chsh is idempotent — if the login shell is already fish, we skip.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "fish"

install_pacman fish
link_tree "$DOTFILES_HOME/.config/fish" "$HOME/.config/fish"

# Ensure fish is a valid login shell in /etc/shells before chsh.
_fish_bin="/usr/bin/fish"
if ! grep -qx "$_fish_bin" /etc/shells 2>/dev/null; then
  echo "$_fish_bin" | sudo tee -a /etc/shells >/dev/null
  ok "added $_fish_bin to /etc/shells"
fi

# Set fish as the login shell if it isn't already.
_current_shell="$(getent passwd "$USER" | cut -d: -f7)"
if [[ "$_current_shell" == "$_fish_bin" ]]; then
  skip "login shell already fish"
else
  if chsh -s "$_fish_bin"; then
    ok "login shell set to fish (takes effect on next login)"
  else
    warn "chsh failed — run manually: chsh -s $_fish_bin"
    _add_warning "chsh failed; login shell not set to fish"
  fi
fi
