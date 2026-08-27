# 000235-yazi.sh -- Yazi terminal file manager (pacman / nix)
# Installs: yazi
# Links:    ~/.config/yazi/yazi.toml
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "yazi"

if is_debian; then
  # Not in the Ubuntu archive (no candidate at all, not even a virtual one) and
  # no upstream .deb -- nixpkgs is the cross-distro source.
  install_nix .#yazi
else
  install_pacman yazi
fi
link_file "$DOTFILES_HOME/.config/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
