# 000003-nix.sh — Nix package manager (tier 2: after pacman, before pkgbuilds)
# Installs: nix (from extra/ — official Arch signed package)
# Links:    ~/.config/nixpkgs/config.nix (allowUnfree = true)
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

# Deploy /etc/nix/nix.conf with experimental-features = nix-command flakes.
# Without this, `nix profile add` fails with "experimental Nix feature
# 'nix-command' is disabled". The config also sets build-users-group.
deploy_etc_file "$DOTFILES_ROOT_ETC/nix/nix.conf" "/etc/nix/nix.conf" 644

# Restart the daemon to pick up the new config (deploy_etc_file may have
# changed nix.conf after the daemon was already running).
sudo systemctl restart nix-daemon 2>/dev/null || true

# Enable + start the nix daemon (multi-user mode). The daemon manages /nix/store
# access so no user-group setup is needed. Starting it is safe — it's a build
# daemon that listens on a socket, doesn't touch the active session.
enable_system_service "nix-daemon.service"

# Link ~/.config/nixpkgs/config.nix — allows unfree packages (brave, proton-
# pass-cli, handbrake, etc. have non-OSI licenses). This is the standard
# imperative nix way (not flakes, not --impure).
mkdir -p "$HOME/.config/nixpkgs"
link_file "$DOTFILES_HOME/.config/nixpkgs/config.nix" \
  "$HOME/.config/nixpkgs/config.nix"

# Verify nix is functional
if command -v nix &>/dev/null; then
  ok "nix installed ($(nix --version 2>/dev/null | head -1))"
else
  warn "nix binary not on PATH after install — check /usr/bin/nix exists"
  _add_warning "nix not on PATH after pacman install"
fi
