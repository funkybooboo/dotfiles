# 000210-cli-utilities.sh — CLI utilities and dev tools (no config needed)
# Installs (pacman): fzf fd eza dust fastfetch jq wl-clipboard zoxide tree
#                    tealdeer unzip rsync ncdu inotify-tools ast-grep 7zip socat
#                    pandoc-cli gum lazydocker act
# Installs (nix):     tdf, timg
# Links:    —
# Enables:  —
# Note: tdf and timg are installed from nixpkgs — hermetic, sandboxed builds,
#       no pkgbuilds/ or rustup nightly provisioning needed. nix handles the
#       nightly Rust toolchain internally inside the sandbox.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "CLI utilities"

install_pacman \
  fzf fd eza dust fastfetch jq wl-clipboard zoxide tree \
  tealdeer unzip rsync ncdu inotify-tools ast-grep 7zip socat \
  pandoc-cli \
  gum lazydocker act

# tdf + timg: installed from nixpkgs — hermetic, sandboxed builds, no pkgbuilds/.
install_nix .#tdf
install_nix .#timg

# gum, lazydocker, act were AUR-only originally but have since landed in extra/.

ok "CLI utilities"
