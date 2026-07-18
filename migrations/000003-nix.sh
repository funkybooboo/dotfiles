# 000003-nix.sh — Nix package manager (tier 2: after pacman, before pkgbuilds)
# Installs: nix (from extra/ — official Arch signed package)
# Links:    —
# Enables:  nix-daemon.service (started — needed for /nix/store access)
# Note: Nix is the second-tier package source per the install priority:
#       pacman → nix → pkgbuilds → sources → flatpak.
#       `nix profile install nixpkgs#<pkg>` installs from nixpkgs (the NixOS
#       community's package collection, PR-reviewed on GitHub with CI, hermetic
#       sandboxed builds, sha256-verified sources, binary cache at
#       cache.nixos.org). This replaces the AUR entirely — packages that
#       aren't in Arch official repos go to nix instead of yay.
#       The nix daemon creates /nix/store and /nix/var on first start.
#       Profile-installed packages land in ~/.nix-profile/bin/ (user-managed,
#       no sudo needed for installs).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "nix"

install_pacman nix

# Enable + start the nix daemon (multi-user mode). The daemon manages /nix/store
# access so no user-group setup is needed. Starting it is safe — it's a build
# daemon that listens on a socket, doesn't touch the active session.
enable_system_service "nix-daemon.service"

# Verify nix is functional
if command -v nix &>/dev/null; then
  ok "nix installed ($(nix --version 2>/dev/null | head -1))"
else
  warn "nix binary not on PATH after install — check /usr/bin/nix exists"
  _add_warning "nix not on PATH after pacman install"
fi
