# 000303-browsers.sh — web browsers + chromium flags
# Installs: firefox chromium
# Builds (local audited PKGBUILDs):  brave-bin, librewolf-bin
# Links:    ~/.config/chromium-flags.conf
# Enables:  —
# Note: Brave and LibreWolf moved here from flatpak back to audited local
#       PKGBUILDs (pkgbuilds/{brave,librewolf}/), per the policy that AUR/3rd-
#       party packages must be owned + audited in-tree and pinned via sha256
#       (+ GPG sig where upstream publishes one — LibreWolf does). Each has an
#       AUDIT.md recording upstream provenance, personally-computed sha256, and
#       a packaging-script review. The flatpak builds they replaced (com.brave.
#       Browser, io.gitlab.librewolf-community) are uninstalled on first run.
#       This is a genuine integrity upgrade for LibreWolf (GPG-signed upstream
#       vs flatpak TLS-only); for Brave it's parity (pinned sha256 vs flatpak
#       TLS) plus pacman-db .desktop/mimetype integration. Debug symbol
#       packages are swept by 000550-cleanup-aur-debug.sh.

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
