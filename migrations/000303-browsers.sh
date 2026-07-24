# 000303-browsers.sh — web browsers + chromium flags
# Installs: firefox chromium
# Nix:     .#brave
# Links:   ~/.config/chromium-flags.conf
# Enables: —
# Note: Brave is installed from nix (via the local flake, which provides
#       allowUnfree + sha256-verified hermetic build). LibreWolf is NO LONGER
#       installed here — it moved to an AUR source build in 000307 (the nix
#       build's distribution/policy layer blocked extension installs).
#       The former flatpak builds (com.brave.Browser,
#       io.gitlab.librewolf-community) are uninstalled on first run.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "browsers"

install_pacman firefox chromium
# Brave: installed from nixpkgs — hermetic sandboxed build, sha256-verified.
# (LibreWolf moved to AUR source build in 000307.)
install_nix .#brave
# Drop the former flatpaks now that the nix packages are in place (so a
# browser is never absent mid-swap).
remove_flatpak com.brave.Browser
remove_flatpak io.gitlab.librewolf-community
link_file "$DOTFILES_HOME/.config/chromium-flags.conf" "$HOME/.config/chromium-flags.conf"
