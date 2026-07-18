# 000303-browsers.sh — web browsers + chromium flags
# Installs: firefox chromium
# Nix:     .#brave .#librewolf
# Links:   ~/.config/chromium-flags.conf
# Enables: —
# Note: Brave and LibreWolf are installed from nix (via the local flake,
#       which provides allowUnfree + sha256-verified hermetic builds). The
#       former flatpak builds (com.brave.Browser,
#       io.gitlab.librewolf-community) are uninstalled on first run.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "browsers"

install_pacman firefox chromium
# Brave + LibreWolf: installed from nixpkgs — hermetic, sandboxed builds,
# sha256-verified, GPG-verified (librewolf). Replaces the former pkgbuilds/.
install_nix .#brave
install_nix .#librewolf
# Drop the former flatpaks now that the nix packages are in place (so a
# browser is never absent mid-swap).
remove_flatpak com.brave.Browser
remove_flatpak io.gitlab.librewolf-community
link_file "$DOTFILES_HOME/.config/chromium-flags.conf" "$HOME/.config/chromium-flags.conf"
