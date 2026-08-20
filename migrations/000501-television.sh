# 000501-television.sh -- television (TUI channel-switcher / launcher)
# Installs: television (now in extra/ -- official Arch package)
# Links:    ~/.config/television/config.toml
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "television"

if is_debian; then
  # Not in apt; take the upstream release binary (tier 2).
  install_gh_release alexpasmantier/television 'x86_64-unknown-linux-gnu' tv
else
  install_pacman television
fi
link_file "$DOTFILES_HOME/.config/television/config.toml" "$HOME/.config/television/config.toml"
