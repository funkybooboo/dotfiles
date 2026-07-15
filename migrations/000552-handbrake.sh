# 000552-handbrake.sh -- HandBrake video transcoder (build from upstream source)
# Installs: base-devel cmake flac fontconfig freetype2 fribidi harfbuzz jansson
#           lame libass libbluray libjpeg-turbo libogg libsamplerate libtheora
#           libvorbis libvpx libxml2 meson nasm ninja numactl opus python speex
#           x264 xz (build deps), libva libdrm (Intel QSV), desktop-file-utils
#           gst-libav gst-plugins-good gtk4 (GTK GUI)
# Links:    --
# Enables:  --
# Note: HandBrake ships no official Arch or AUR package that matches the
#       upstream-recommended build (third-party distro/AUR builds are explicitly
#       flagged as broken by upstream -- see the "Warning about broken
#       third-party builds" note in the HandBrake docs). The supported path is
#       to build from source: the upstream repo lives in the dotfiles git
#       submodule sources/HandBrake (initialized in preflight), configure, build,
#       and `sudo make --directory=build install` (installs ghb + HandBrakeCLI to
#       the default prefix /usr/local, plus the .desktop and hicolor icon
#       entries). setup.sh step 10b recognises the configure-generated
#       build/Makefile and re-runs `make -C build && sudo make -C build install`
#       after each submodule roll-forward, so re-running setup.sh keeps HandBrake
#       current without re-cloning. This migration is a one-shot bootstrap: once
#       ghb is installed at /usr/local/bin/ghb it skips the long configure/build
#       paso through the cheaper setup.sh roll-forward path.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "HandBrake"

# -----------------------------------------------------------------------------
# Build dependencies (HandBrake 1.9.0 docs: developer/install-dependencies-arch
# + developer/build-linux). install_pacman is idempotent (--needed) and non-
# fatal; base-devel/cmake/meson/ninja/python/xz are almost certainly already
# present from earlier migrations and are simply skipped.
# -----------------------------------------------------------------------------
install_pacman \
  base-devel cmake flac fontconfig freetype2 fribidi harfbuzz jansson lame \
  libass libbluray libjpeg-turbo libogg libsamplerate libtheora libvorbis \
  libvpx libxml2 meson nasm ninja numactl opus python speex x264 xz

# Intel Quick Sync Video (optional) -- present so configure auto-detects it.
install_pacman libva libdrm

# GTK graphical interface (ghb) -- without these only HandBrakeCLI builds.
install_pacman desktop-file-utils gst-libav gst-plugins-good gtk4

# -----------------------------------------------------------------------------
# HandBrake source lives in the dotfiles git submodule sources/HandBrake
# (initialized in preflight). Verify it is populated.
# -----------------------------------------------------------------------------
HB_DIR="$REPO_ROOT/sources/HandBrake"

# A submodule checkout has a `.git` FILE (gitlink), not a dir -- use -e.
if [[ ! -e "$HB_DIR/.git" ]]; then
  fail "sources/HandBrake submodule not populated"
  _add_error "sources/HandBrake submodule missing; run 'git -C ~/dotfiles submodule update --init sources/HandBrake'"
  return 0
fi
ok "HandBrake source (submodule sources/HandBrake)"

# -----------------------------------------------------------------------------
# Bootstrap build + install. Idempotent: once ghb is installed at the default
# prefix (/usr/local/bin/ghb) we skip the heavy configure+build paso entirely
# -- the `update` script (Step 20) handles roll-forward rebuilds after git pull.
# Default prefix is /usr/local (HandBrake make/configure.py: cfg.prefix_dir).
# -----------------------------------------------------------------------------
if [[ -x /usr/local/bin/ghb ]]; then
  skip "HandBrake already installed (/usr/local/bin/ghb) -- use setup.sh to rebuild"
  return 0
fi

info "configuring + building HandBrake (this downloads + compiles contribs; takes a while)..."
# ./configure --launch both configures and builds (--launch-jobs drives the
# parallel build, --launch kicks it off immediately). Output dir: build/.
if ( cd "$HB_DIR" && ./configure --launch-jobs="$(nproc)" --launch ); then
  ok "HandBrake built (build/)"
else
  fail "HandBrake build failed"
  _add_error "HandBrake configure/build failed; run './configure --launch-jobs=\$(nproc) --launch' in $HB_DIR"
  return 0
fi

info "installing HandBrake -> /usr/local (sudo make --directory=build install)..."
if ( cd "$HB_DIR" && sudo make --directory=build install ); then
  ok "HandBrake installed (ghb at /usr/local/bin/ghb)"
else
  fail "HandBrake install failed"
  _add_error "HandBrake install failed; run 'sudo make --directory=build install' in $HB_DIR"
  return 0
fi