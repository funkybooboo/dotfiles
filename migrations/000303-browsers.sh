# 000303-browsers.sh — web browsers + chromium flags
# Installs: firefox chromium
# Nix:     .#brave
# Links:   ~/.config/chromium-flags.conf
# Enables: —
# Note: Brave is installed from nix (via the local flake, which provides
#       allowUnfree + sha256-verified hermetic build). LibreWolf + Mullvad
#       Browser are installed in 000307/000308 from upstream release assets
#       (codeberg/github), NOT here.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "browsers"

install_pacman firefox chromium
# Brave: installed from nixpkgs -- hermetic sandboxed build, sha256-verified.
# (LibreWolf + Mullvad Browser live in 000307/000308 as upstream release
#  assets -- see those migrations.)
install_nix .#brave
link_file "$DOTFILES_HOME/.config/chromium-flags.conf" "$HOME/.config/chromium-flags.conf"
