# 000329-ladybird.sh -- Ladybird browser (from-source build tracking upstream master)
# Installs:        autoconf-archive base-devel ccache cmake curl git less libglvnd
#                  libpulse nasm ninja python qt6-base qt6-positioning qt6-tools
#                  qt6-wayland ttf-liberation tar unzip vulkan-headers wayland
#                  xcb-util-wm zip
#                  (upstream's Arch build-dependency list, plus two additions:
#                  qt6-wayland for the native Wayland platform plugin on this
#                  Hyprland desktop, and vulkan-headers which upstream's list
#                  omits -- the Compositor target includes <vulkan/vulkan.h>
#                  without linking Vulkan::Headers, so it only compiles where
#                  system vulkan headers exist. libglvnd is the real package
#                  behind upstream's virtual "libgl" name)
# Links:           --
# Enables:         --
# Note: Ladybird (https://github.com/LadybirdBrowser/ladybird) publishes no
#       release assets and Arch carries no package (AUR excluded by policy),
#       so this is a Tier 4 build-from-source install that tracks upstream
#       master. The source is a migration-owned shallow clone at
#       ~/.local/share/ladybird/src -- NOT a sources/ submodule: a submodule
#       pins one commit and updates only via a committed pointer bump, the
#       opposite of following a moving master. Third-party deps (skia, ffmpeg,
#       icu, openssl, ...) are built by vcpkg under src/Build/vcpkg-release
#       with a binary cache in src/Build/caches; the GUI toolkit is system Qt
#       (upstream needs 6.10+; this machine has 6.12). The Rust toolchain
#       comes from mise (000202): ladybird links Rust crates through its
#       rust_crate cmake module, so cargo must be on PATH.
#
#       Build and install run upstream's Meta/ladybird.py install (Release
#       preset: RelWithDebInfo, ninja + ccache, build dir src/Build/release),
#       which drives cmake's install rules into ~/.local: bin/Ladybird plus
#       libexec helper processes and lib shared libraries, and -- via
#       ENABLE_INSTALL_FREEDESKTOP_FILES=ON -- the .desktop, icon, dbus
#       service and metainfo into ~/.local/share. Nothing is written to /usr
#       (the /usr system-integration install rules are EXCLUDE_FROM_ALL).
#       The installed binary locates its libraries through the upstream
#       $ORIGIN:$ORIGIN/../lib install rpath. CMAKE_INSTALL_PREFIX is set at
#       first configure only: ladybird.py's own configure path accepts no
#       extra -D args, so the migration runs `cmake --preset Release` itself
#       that one time; every later run finds build.ninja and skips configure
#       (ninja reconfigures incrementally when upstream cmake files change).
#       The remaining cache flags mirror upstream's own flatpak manifest, the
#       closest known-good prefix install: ENABLE_INSTALL_FREEDESKTOP_FILES=ON
#       (.desktop/icon/dbus service), ENABLE_INSTALL_HEADERS=OFF (runtime
#       install, no header dump into ~/.local/include) and BUILD_TESTING=OFF
#       (ninja's install target builds everything in `all`, so without this
#       the whole Tests/ tree would be compiled for nothing).
#
#       Roll-forward: every run fetches master (depth 1); when the tip moved,
#       or the installed binary is missing, it rebuilds and re-installs, then
#       re-stamps. The stamp follows the sources/* build convention:
#       ~/.cache/dotfiles-sources/ladybird. The first build is long (vcpkg
#       compiles ~35 ports, skia most of all); later builds are incremental
#       (ccache + the vcpkg binary cache + the shallow tree). Delete the
#       stamp or ~/.local/bin/Ladybird to force a rebuild.
#
#       Memory: compile jobs are capped at 16 and link jobs at 2
#       (LAGOM_LINK_POOL_SIZE, upstream's documented remedy for limited RAM)
#       so a 30 GiB machine with the desktop session resident cannot OOM at
#       link time. That flag is currently broken upstream: rust_crate.cmake's
#       `set_property(GLOBAL PROPERTY JOB_POOLS "${JOB_POOLS};cargo=1")`
#       reads a nonexistent ${JOB_POOLS} VARIABLE and REPLACES the global
#       property, erasing the link_pool definition that use_linker.cmake
#       registered for LAGOM_LINK_POOL_SIZE while every link edge keeps its
#       pool reference -- ninja then dies at parse time with "unknown pool
#       name 'link_pool'". The migration therefore patches that one line to
#       the intended APPEND form before configuring, guarded by an
#       exact-match grep so it self-removes once upstream fixes it; a run
#       that reconfigures also re-checks the generated rules.ninja and, if
#       the pool still failed to land, degrades to an uncapped build with a
#       warning instead of dying.
#
#       Rust pin: rust_crate.cmake hard-codes -Dwarnings, so any API the
#       current stable rust deprecates is fatal (rust 1.99 deprecates
#       fetch_update, which master still calls). The build is pinned to
#       RUSTUP_TOOLCHAIN=1.98.0 -- the newest rust that compiles today's
#       master clean; the mise-managed rust installs are rustup shims, so
#       that env var selects the pinned toolchain over both the global mise
#       default and the repo's versionless rust-toolchain.toml, and the pin
#       installs through mise on machines that lack it. Bump the pin when
#       master stops building under it (rustc "no method" errors mean master
#       adopted newer-rust APIs), and drop it if upstream ever stops
#       hard-coding -Dwarnings.
#
#       Recovery: if an upstream restructure ever breaks the incremental
#       build, run ./Meta/ladybird.py rebuild in the source dir -- the vcpkg
#       binary cache keeps that from being a full redo.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "ladybird"

LADYBIRD_SRC="$HOME/.local/share/ladybird/src"
LADYBIRD_BIN="$HOME/.local/bin/Ladybird"
LADYBIRD_STAMP="$HOME/.cache/dotfiles-sources/ladybird"
LADYBIRD_BUILD="$LADYBIRD_SRC/Build/release"

# --- build dependencies (upstream's Arch list; see header) --------------------
install_pacman autoconf-archive base-devel ccache cmake curl git less libglvnd \
    libpulse nasm ninja python qt6-base qt6-positioning qt6-tools qt6-wayland \
    ttf-liberation tar unzip vulkan-headers wayland xcb-util-wm zip

# --- toolchain gate (non-fatal skip) -------------------------------------------
# cmake/ninja/nasm/ccache come from the pacman list above, cc/c++ from
# base-devel, cargo from mise-managed rust (000202). The vulkan headers are
# checked by path because the Compositor target compiles <vulkan/vulkan.h>
# through LibGfx without linking Vulkan::Headers (see header note), so the
# system package is a hard requirement that a failed install_pacman step
# must not let reach the build. Anything missing means an install step or
# mise failed on this machine; skipping with a warning beats dying (or
# worse, OOMing) deep inside the build.
if ! command -v cmake >/dev/null 2>&1 \
   || ! command -v ninja >/dev/null 2>&1 \
   || ! command -v nasm >/dev/null 2>&1 \
   || ! command -v ccache >/dev/null 2>&1 \
   || ! command -v cc >/dev/null 2>&1 \
   || ! command -v cargo >/dev/null 2>&1; then
  warn "build toolchain incomplete (need cmake, ninja, nasm, ccache, cc, cargo) -- skipping"
  _add_warning "ladybird: build toolchain incomplete; not built this run"
  return 0 2>/dev/null || exit 0
fi
if [[ ! -f /usr/include/vulkan/vulkan.h ]]; then
  warn "vulkan-headers not installed (install_pacman failed?) -- skipping"
  _add_warning "ladybird: /usr/include/vulkan/vulkan.h missing; not built this run"
  return 0 2>/dev/null || exit 0
fi

# --- pin the rust toolchain (see header) ----------------------------------------
# rust_crate.cmake hard-codes -Dwarnings, so a rust that deprecates an API
# ladybird still uses is fatal (rust 1.99 deprecates fetch_update). The
# rustup shim env selects the pinned toolchain over the global mise default
# AND over the repo's versionless rust-toolchain.toml; the version-match
# check also catches a cargo that is NOT a rustup shim (it would silently
# ignore the pin and build with whatever it is).
LADYBIRD_RUST="1.98.0"
if ! RUSTUP_TOOLCHAIN="$LADYBIRD_RUST" rustc --version 2>/dev/null | grep -q "rustc $LADYBIRD_RUST"; then
  info "installing rust $LADYBIRD_RUST via mise (ladybird's -Dwarnings pin; see header)"
  if ! command -v mise >/dev/null 2>&1; then
    warn "mise not found -- cannot provide rust $LADYBIRD_RUST -- skipping"
    _add_warning "ladybird: mise missing; rust pin $LADYBIRD_RUST not installable"
    return 0 2>/dev/null || exit 0
  fi
  if ! mise install "rust@$LADYBIRD_RUST" \
     || ! RUSTUP_TOOLCHAIN="$LADYBIRD_RUST" rustc --version 2>/dev/null | grep -q "rustc $LADYBIRD_RUST"; then
    warn "rust $LADYBIRD_RUST unavailable (mise install failed?) -- skipping"
    _add_warning "ladybird: rust pin $LADYBIRD_RUST not installable; not built this run"
    return 0 2>/dev/null || exit 0
  fi
fi
export RUSTUP_TOOLCHAIN="$LADYBIRD_RUST"
info "rust toolchain pinned to $LADYBIRD_RUST"

# --- clone (first run only) -----------------------------------------------------
mkdir -p "$(dirname "$LADYBIRD_SRC")"
if [[ ! -d "$LADYBIRD_SRC/.git" ]]; then
  # A non-repo remnant from an interrupted clone makes `git clone` fail; clear it.
  if [[ -e "$LADYBIRD_SRC" ]]; then
    info "removing non-repo remnant at ${LADYBIRD_SRC/$HOME/\~}"
    rm -rf "$LADYBIRD_SRC"
  fi
  info "cloning ladybird (shallow, master)"
  if ! git clone --depth 1 https://github.com/LadybirdBrowser/ladybird.git "$LADYBIRD_SRC"; then
    warn "clone failed -- skipping"
    _add_warning "ladybird: git clone failed"
    return 0 2>/dev/null || exit 0
  fi
fi

# --- roll-forward: fetch master, compare against the last-built commit ---------
# A failed fetch is non-fatal: fall back to the tip already on disk so an
# offline run still (re)builds whatever is present when the binary is missing.
if ! git -C "$LADYBIRD_SRC" fetch --depth 1 origin master 2>/dev/null; then
  warn "fetch failed (offline?) -- building from the local tip"
  _add_warning "ladybird: upstream fetch failed; using the local master tip"
fi
tip="$(git -C "$LADYBIRD_SRC" rev-parse FETCH_HEAD 2>/dev/null \
       || git -C "$LADYBIRD_SRC" rev-parse HEAD 2>/dev/null || true)"
if [[ -z "$tip" ]]; then
  warn "cannot resolve the source tree tip -- skipping"
  _add_warning "ladybird: could not resolve git tip in the source tree"
  return 0 2>/dev/null || exit 0
fi

# Fast path: the installed binary was built from exactly this commit.
if [[ -x "$LADYBIRD_BIN" && -f "$LADYBIRD_STAMP" ]] \
   && [[ "$(cat "$LADYBIRD_STAMP" 2>/dev/null || true)" == "$tip" ]]; then
  skip "ladybird (built from master@${tip:0:10})"
  return 0 2>/dev/null || exit 0
fi

# --- move the tree to the fetched tip --------------------------------------------
# reset --hard rewrites only tracked files; the untracked src/Build tree
# (vcpkg checkout + build + caches) survives, which is what keeps upgrades
# incremental. Local edits to the tree are discarded -- it is migration-owned.
if ! git -C "$LADYBIRD_SRC" reset --hard "$tip" >/dev/null; then
  warn "git reset to master@${tip:0:10} failed -- skipping"
  _add_warning "ladybird: git reset to the fetched tip failed"
  return 0 2>/dev/null || exit 0
fi

# --- patch the upstream JOB_POOLS clobber (see header) ---------------------------
# Applied after reset --hard (which restores the broken upstream line) and
# before configuring, so both fresh configs and reconfigs see the fixed tree.
# Guarded by an exact-match grep: when upstream fixes or rewrites the line,
# the grep misses and the pool verification below degrades gracefully.
if grep -q 'set_property(GLOBAL PROPERTY JOB_POOLS "${JOB_POOLS};cargo=1")' \
     "$LADYBIRD_SRC/Meta/CMake/rust_crate.cmake"; then
  info "patching rust_crate.cmake JOB_POOLS clobber (upstream bug; see header)"
  sed -i \
    's|set_property(GLOBAL PROPERTY JOB_POOLS "${JOB_POOLS};cargo=1")|set_property(GLOBAL APPEND PROPERTY JOB_POOLS "cargo=1")|' \
    "$LADYBIRD_SRC/Meta/CMake/rust_crate.cmake"
fi

# --- build parallelism (see header note) ------------------------------------------
jobs="$(nproc)"
if (( jobs > 16 )); then
  jobs=16
fi

# --- build environment (mirrors ladybird.py's configure_build_env) ----------------
# The first cmake configure needs VCPKG_ROOT + the vcpkg checkout on PATH, and
# the CMakePresets binaryDir expansion reads LADYBIRD_SOURCE_DIR. ladybird.py
# exports these in its own process; we export them for our configure call.
export LADYBIRD_SOURCE_DIR="$LADYBIRD_SRC"
export VCPKG_ROOT="$LADYBIRD_SRC/Build/vcpkg-release"
export VCPKG_MAX_CONCURRENCY="$jobs"
export PATH="$VCPKG_ROOT:$PATH"

# --- configure: first run, or healing a tree broken by the pool bug --------------
# Normally configure happens once (build.ninja absent). A tree configured with
# the broken upstream rust_crate.cmake has links referencing link_pool with no
# definition in the generated rules.ninja -- ninja fails at parse time -- so
# also reconfigure when that state is detected; the patch above makes the
# reconfigure emit the missing definition.
need_configure=0
if [[ ! -f "$LADYBIRD_BUILD/build.ninja" ]]; then
  need_configure=1
elif grep -q "^CMAKE_JOB_POOL_LINK:STRING=link_pool" "$LADYBIRD_BUILD/CMakeCache.txt" 2>/dev/null \
     && ! grep -q "^pool link_pool" "$LADYBIRD_BUILD/CMakeFiles/rules.ninja" 2>/dev/null; then
  info "healing build tree: link edges reference a pool that was never defined (the upstream bug)"
  need_configure=1
fi

if (( need_configure )); then
  info "bootstrapping vcpkg (clone at upstream's pinned baseline + binary build)"
  if ! (cd "$LADYBIRD_SRC" && ./Meta/ladybird.py vcpkg --jobs "$jobs"); then
    warn "vcpkg bootstrap failed -- skipping"
    _add_warning "ladybird: vcpkg bootstrap failed"
    return 0 2>/dev/null || exit 0
  fi
  info "configuring cmake (Release preset, install prefix ~/.local)"
  if ! (cd "$LADYBIRD_SRC" && cmake --preset Release -B Build/release \
        -DCMAKE_C_COMPILER="$(command -v cc)" \
        -DCMAKE_CXX_COMPILER="$(command -v c++)" \
        -DCMAKE_INSTALL_PREFIX="$HOME/.local" \
        -DENABLE_INSTALL_FREEDESKTOP_FILES=ON \
        -DENABLE_INSTALL_HEADERS=OFF \
        -DBUILD_TESTING=OFF \
        -DLAGOM_LINK_POOL_SIZE=2); then
    warn "cmake configure failed -- skipping (a first-run failure here is usually a vcpkg port build; re-run to resume)"
    _add_warning "ladybird: cmake configure failed"
    return 0 2>/dev/null || exit 0
  fi

  # The link pool must actually be defined or ninja dies at parse time. If the
  # patch above missed (upstream changed the line), degrade: clear the pool
  # from the cache and reconfigure, then continue uncapped with a warning
  # instead of failing the run. Nothing else changes.
  if ! grep -q "^pool link_pool" "$LADYBIRD_BUILD/CMakeFiles/rules.ninja" 2>/dev/null; then
    warn "link pool missing after configure -- upstream rust_crate.cmake changed? dropping the cap"
    if (cd "$LADYBIRD_SRC" && cmake --preset Release -B Build/release \
          -DLAGOM_LINK_POOL_SIZE:STRING= -DCMAKE_JOB_POOL_LINK:STRING=) >/dev/null 2>&1; then
      warn "continuing WITHOUT the link-job cap (-j$jobs also governs link steps)"
      _add_warning "ladybird: link pool unavailable; build ran without the link-job cap"
    else
      warn "reconfigure without the link pool failed -- skipping"
      _add_warning "ladybird: reconfigure without link pool failed"
      return 0 2>/dev/null || exit 0
    fi
  fi
fi

# --- build + install ----------------------------------------------------------------
info "building ladybird master@${tip:0:10} (-j$jobs) -- the first build compiles all vcpkg deps, expect a long run"
if ! (cd "$LADYBIRD_SRC" && ./Meta/ladybird.py install --jobs "$jobs"); then
  warn "build or install failed -- not stamping; the next run retries the remainder"
  _add_warning "ladybird: build/install failed; re-run to resume, or run './Meta/ladybird.py rebuild' in ${LADYBIRD_SRC/$HOME/\~}"
  return 0 2>/dev/null || exit 0
fi

if [[ ! -x "$LADYBIRD_BIN" ]]; then
  warn "install finished but ${LADYBIRD_BIN/$HOME/\~} is missing"
  _add_error "ladybird: install completed without bin/Ladybird"
  return 0 2>/dev/null || exit 0
fi

mkdir -p "$(dirname "$LADYBIRD_STAMP")"
printf '%s\n' "$tip" > "$LADYBIRD_STAMP"
ok "ladybird master@${tip:0:10} -> ${LADYBIRD_BIN/$HOME/\~}"
info "desktop entry, icon and dbus service installed under ~/.local/share"
