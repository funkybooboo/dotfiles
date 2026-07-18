# 000500-calcure.sh — calcure (TUI calendar) + config
# Installs: calcure (via nix — nixpkgs#calcure)
# Links:    ~/.config/calcure/config.ini
# Enables:  —
# Note: calendar-tui (in personal-admin-scripts) launches calcure. Calcure
#       is installed from nixpkgs (tier 2) — hermetic, sha256-verified,
#       sandboxed build with all Python deps resolved inside the nix store.
#       This replaces the former install_aur (the AUR package was just a
#       thin wrapper that pip-installed from PyPI; nix does the same but
#       with stronger trust guarantees and no anonymous-uploader risk).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "calcure"

install_nix nixpkgs#calcure
link_file "$DOTFILES_HOME/.config/calcure/config.ini" "$HOME/.config/calcure/config.ini"
