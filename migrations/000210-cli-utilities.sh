# 000210-cli-utilities.sh — CLI utilities and dev tools (no config needed)
# Installs (pacman): fzf fd eza dust fastfetch jq wl-clipboard zoxide tree
#                    tealdeer unzip rsync ncdu inotify-tools ast-grep 7zip socat
#                    pandoc-cli (build dep for timg's manpage) gum lazydocker act
# Builds (local):    tdf (cargo, needs nightly), timg (cmake)
# Links:    —
# Enables:  —
# Note: tdf and timg are built from upstream source via local PKGBUILDs
#       (pkgbuilds/) — no yay/AUR at runtime. tdf requires nightly Rust
#       (upstream rust-toolchain.toml); the nightly toolchain is provisioned
#       via rustup (official Rust toolchain manager) just-in-time. pandoc-cli
#       is installed first so timg's PKGBUILD can regenerate its manpage.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "CLI utilities"

install_pacman \
  fzf fd eza dust fastfetch jq wl-clipboard zoxide tree \
  tealdeer unzip rsync ncdu inotify-tools ast-grep 7zip socat \
  pandoc-cli \
  gum lazydocker act

# tdf requires nightly Rust (upstream pins it via rust-toolchain.toml).
# Provision the nightly toolchain via the mise-managed rustup binary (at
# ~/.cargo/bin/rustup — the same binary mise installed when it provisioned
# the stable Rust toolchain). Prepend ~/.cargo/bin so the rustup cargo proxy
# is used by makepkg (a system/pacman cargo would ignore the nightly toolchain
# override). migrate.sh may run non-interactively without the user's shell
# having activated mise shims.
export PATH="$HOME/.cargo/bin:$PATH"
if command -v rustup &>/dev/null; then
  rustup toolchain install nightly 2>/dev/null || \
    warn "rustup nightly install failed — tdf build may fail"
else
  warn "rustup not found — tdf needs nightly Rust; install rustup first"
  _add_warning "rustup missing; tdf build needs nightly Rust"
fi

# tdf + timg: build from upstream source via local PKGBUILDs (no AUR).
install_local_pkgbuild tdf
install_local_pkgbuild timg

# gum, lazydocker, act were AUR-only originally but have since landed in extra/.

ok "CLI utilities"
