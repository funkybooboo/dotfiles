# 000501-television.sh -- television (TUI channel-switcher / launcher)
# Installs: television
# Links:    ~/.config/television/config.toml
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "television"

if is_debian; then
  install_gh_release alexpasmantier/television 'x86_64-unknown-linux-gnu' tv || \
    _add_warning "television: install manually on Debian (https://github.com/alexpasmantier/television/releases)"
else
  install_aur television
fi
link_file "$DOTFILES_HOME/.config/television/config.toml" "$HOME/.config/television/config.toml"
