# 000309-chromium.sh -- ungoogled-chromium (nix flake) + chromium-flags.conf + PATH wrapper
# Nix:    .#ungoogled-chromium
# Links:  ~/.config/chromium-flags.conf, ~/.local/bin/chromium (wrapper)
# Enables: --
# Note: one piece of software = one migration. ungoogled-chromium is the
#       privacy-hardened chromium build (Google integration, background
#       updater and telemetry stripped). Tier story: Arch's official repos
#       do not carry it (AUR only -- excluded by policy), Flathub does not
#       carry it, and upstream's portable-linux release assets run weeks
#       behind with no published checksums (they fail tier 2's verify
#       policy), so nix is the first tier that can serve it. The binary-cache
#       hit at our pinned nixpkgs was verified with 'nix build --dry-run'
#       (166 MiB fetched, nothing built) on 2026-11-23; ungoogled-chromium is
#       free, so hydra builds it continuously -- unlike unfree brave, which
#       every nix install compiles locally.
#       The switch from pacman's chromium is seamless: nixpkgs tracked the
#       exact same upstream release as Arch's extra/ build (158.0.8127.36 on
#       both, 2026-11-23), so ~/.config/chromium carries over with no
#       profile downgrade, and the binary name (chromium) and WM class are
#       unchanged, so gpauth's --browser chromium and the hypr window rules
#       keep working (the nix desktop entry lands as chromium-browser.desktop
#       rather than chromium.desktop; nothing referenced the old id). If a
#       future pin ever LAGS the installed profile version (chromium refuses
#       to open a newer-created profile), re-add pacman chromium temporarily
#       rather than downgrading the profile.
#       The ~/.local/bin/chromium wrapper exists because nixpkgs' chromium
#       wrapper does not read chromium-flags.conf (an Arch-wrapper feature);
#       the wrapper feeds the tracked flags file to the real binary, keeping
#       the Wayland ozone / dark-mode / overscroll behavior.
#       mermaid-cli (nix) drives a browser via PUPPETEER_EXECUTABLE_PATH in
#       environment.d/apps.conf -- that line follows the binary into the nix
#       profile and points at the REAL binary, not this flags wrapper.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "chromium (ungoogled)"

install_nix .#ungoogled-chromium
link_file "$DOTFILES_HOME/.config/chromium-flags.conf" "$HOME/.config/chromium-flags.conf"
link_file "$DOTFILES_HOME/.local/bin/chromium" "$HOME/.local/bin/chromium"

# Retire the pacman build: its Arch-wrapper era (chromium-flags.conf handling,
# /usr/bin/chromium) ends here; the nix build + PATH wrapper replace it.
remove_pkg chromium

ok "chromium (ungoogled)"
