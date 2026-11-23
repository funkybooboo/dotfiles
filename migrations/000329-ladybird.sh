# 000329-ladybird.sh -- ladybird browser (dev-driven from-source build)
# Installs:        autoconf-archive base-devel ccache cmake curl git less libglvnd
#                  libpulse nasm ninja python qt6-base qt6-positioning qt6-tools
#                  qt6-wayland ttf-liberation tar unzip vulkan-headers wayland
#                  xcb-util-wm zip
#                  (upstream's Arch build-dependency list, plus qt6-wayland for
#                  the native Wayland platform plugin on this Hyprland desktop,
#                  and vulkan-headers which upstream's list omits -- the
#                  Compositor target compiles <vulkan/vulkan.h> without linking
#                  Vulkan::Headers; libglvnd is the real package behind
#                  upstream's virtual "libgl" name)
# Links:           ~/.local/bin/ladybird-dev
# Enables:         --
# Note: Ladybird (https://github.com/LadybirdBrowser/ladybird) is DAILY-DRIVEN
#       from source and developed against: the operator fixes bugs in the
#       tree, rebuilds, daily-drives the fixed browser, and only then opens
#       the PR. The installed browser must therefore always be the local
#       build.
#
#       Why still from source (tier 4) with the alpha out (2026.47.7,
#       2026-11-23): upstream's prebuilt channels are an apt repo (Ubuntu),
#       an rpm repo (Fedora), a flatpak, and a macOS dmg -- nothing Arch can
#       consume (same shape as espanso's Debian-only .deb); flatpak was
#       declined by the operator; and nix cannot host this workflow even
#       though nixpkgs carries ladybird and binary-cache-hits at our pin
#       ('nix build --dry-run': 137 MiB fetched, nothing built, verified
#       2026-11-23) -- a sandboxed derivation rebuilt from scratch on every
#       change is the opposite of a fix-and-drive dev loop. From source it
#       remains, driven by the loop below.
#
#       MODEL (the homelab pattern): ~/Projects/ladybird is an OPERATOR-OWNED
#       dev tree. Migrations never clone, fetch, reset, or build it -- the
#       previous 000329 (see git history) owned a shallow clone at
#       ~/.local/share/ladybird/src and HARD-RESET it to master's tip on
#       every migrate run, correct for a consumed build but fatal for a dev
#       tree: local edits were discarded and fix-and-drive was impossible.
#       This migration only provides the environment: the pacman build deps,
#       the ladybird-dev helper, a one-time guarded move of the old tree into
#       ~/Projects, the fork remote, and sweeps of migration-era fossils
#       (the roll-forward stamp). Fresh machines get deps + helper
#       immediately; clone LadybirdBrowser/ladybird to ~/Projects/ladybird
#       and run ladybird-dev when you want the browser -- migrate.sh never
#       triggers a multi-hour build.
#
#       WORKFLOW: git switch -c fix/foo -> edit -> ladybird-dev (incremental
#       install, ~minutes) -> daily-drive the fix -> push to the fork
#       (funkybooboo/ladybird, kept in sync with upstream by setup.sh 10a)
#       -> gh pr create. Rebase onto origin/master and rebuild whenever
#       upstream moves; after a merge, git pull + ladybird-dev returns the
#       driver to stock master. ladybird-dev update rolls master ff-only and
#       rebuilds (it refuses on fix branches or a dirty tree). The browser
#       profile (~/.config/Ladybird and friends) is untouched by builds, so
#       daily driving survives every rebuild.
#
#       The BUILD ITSELF and its traps (the rust toolchain pin for
#       rust_crate.cmake's -Dwarnings hard-code, the JOB_POOLS clobber patch,
#       the vcpkg runtime libs copied into ~/.local/lib for the
#       $ORIGIN:$ORIGIN/../lib rpath, the 16/2 compile/link job caps) live in
#       the ladybird-dev helper this migration links into ~/.local/bin. Do
#       not duplicate that logic here.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "ladybird (dev-driven)"

# --- build dependencies ---------------------------------------------------------
install_pacman autoconf-archive base-devel ccache cmake curl git less libglvnd \
    libpulse nasm ninja python qt6-base qt6-positioning qt6-tools qt6-wayland \
    ttf-liberation tar unzip vulkan-headers wayland xcb-util-wm zip

# --- the dev-loop helper (owns the build itself) -----------------------------------
link_file "$DOTFILES_HOME/.local/bin/ladybird-dev" "$HOME/.local/bin/ladybird-dev"

LADYBIRD_REPO="$HOME/Projects/ladybird"
OLD_TREE="$HOME/.local/share/ladybird/src"

# --- one-time: move the old migration-owned tree to ~/Projects --------------------
# Same-filesystem rename, so the 13 GB tree (vcpkg deps + build caches) moves
# intact. The next ladybird-dev run pays one reconfigure (the build dir caches
# the old absolute paths); a plain shallow tree is left alone -- cloning is
# the operator's call.
if [[ -d "$LADYBIRD_REPO/.git" ]]; then
  skip "dev tree already at ~/Projects/ladybird"
elif [[ -d "$OLD_TREE/.git" ]]; then
  info "moving the old migration-owned tree to ~/Projects/ladybird"
  mkdir -p "$HOME/Projects"
  if mv "$OLD_TREE" "$LADYBIRD_REPO"; then
    rmdir "$HOME/.local/share/ladybird" 2>/dev/null || true
    ok "tree moved to ~/Projects/ladybird"
    info "the next ladybird-dev run reconfigures once (stale build-dir paths)"
  else
    warn "tree move failed"
    _add_warning "ladybird: tree move to ~/Projects failed; resolve manually"
  fi
else
  skip "ladybird dev tree (clone LadybirdBrowser/ladybird to ~/Projects/ladybird when you want to build it)"
fi

# --- fork remote (the PR workflow pushes here; setup.sh 10a syncs it) ---------------
if [[ -d "$LADYBIRD_REPO/.git" ]] \
   && ! git -C "$LADYBIRD_REPO" remote get-url fork >/dev/null 2>&1; then
  if git -C "$LADYBIRD_REPO" remote add fork \
       https://github.com/funkybooboo/ladybird.git; then
    ok "fork remote added (funkybooboo/ladybird)"
  else
    warn "could not add the fork remote"
    _add_warning "ladybird: fork remote not added; PR pushes need it"
  fi
fi

# --- shallow-clone hint (full history for rebases + PRs) -----------------------------
if [[ -d "$LADYBIRD_REPO/.git" ]] \
   && [[ "$(git -C "$LADYBIRD_REPO" rev-parse --is-shallow-repository 2>/dev/null)" == "true" ]]; then
  info "tree is a shallow clone -- 'git -C ~/Projects/ladybird fetch --unshallow' gives full history (rebases + PRs)"
fi

# --- retire the migration-era roll-forward stamp ---------------------------------------
# The stamp belonged to the old fetch/reset/rebuild-on-migrate model. The dev
# tree is never auto-rolled, so there is nothing to compare against.
if [[ -f "$HOME/.cache/dotfiles-sources/ladybird" ]]; then
  rm -f "$HOME/.cache/dotfiles-sources/ladybird"
  ok "swept the retired roll-forward stamp"
fi
