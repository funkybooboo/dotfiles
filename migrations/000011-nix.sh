# 000011-nix.sh — Nix package manager (tier 2: after pacman, before pkgbuilds)
# Installs: nix (from extra/ — official Arch signed package)
# Links:    —
# Enables:  nix-daemon.service (started — needed for /nix/store access)
# Note: Nix is the second-tier package source per the install priority:
#       pacman → nix → sources → flatpak.
#       `nix profile add .#<pkg>` installs from our local flake (flake.nix),
#       which wraps nixpkgs with allowUnfree = true and pins the nixpkgs
#       revision via flake.lock. This replaces the AUR entirely.
#       Runs after 000010-base so base-devel + curl are available.

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

# Verify nix is functional
if command -v nix &>/dev/null; then
  ok "nix installed ($(nix --version 2>/dev/null | head -1))"
else
  warn "nix binary not on PATH after install — check /usr/bin/nix exists"
  _add_warning "nix not on PATH after pacman install"
fi
