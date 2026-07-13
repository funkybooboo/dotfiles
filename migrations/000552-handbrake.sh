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
#       to build from source: clone github.com/HandBrake/HandBrake.git into
#       ~/sources/HandBrake, configure, build, and `sudo make --directory=build
#       install` (installs ghb + HandBrakeCLI to the default prefix /usr/local,
#       plus the .desktop and hicolor icon entries). The update script's Step 20
#       rebuild harness recognises the configure-generated build/Makefile and
#       re-runs `make -C build && sudo make -C build install` after each git
#       pull, so a `update` keeps HandBrake current without re-cloning.
#       This migration is a one-shot bootstrap: once ghb is installed at
#       /usr/local/bin/ghb it skips the long configure/build paso through the
#       cheaper update-script path.

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
# Clone the upstream repo into ~/sources/HandBrake (idempotent).
# -----------------------------------------------------------------------------
HB_DIR="$HOME/sources/HandBrake"

if [[ -d "$HB_DIR/.git" ]]; then
  skip "HandBrake repo (already cloned)"
else
  info "cloning HandBrake -> ~/sources/HandBrake..."
  mkdir -p "$HOME/sources"
  if git clone --quiet https://github.com/HandBrake/HandBrake.git "$HB_DIR"; then
    ok "HandBrake cloned"
  else
    fail "failed to clone HandBrake"
    _add_error "HandBrake clone failed; run 'git clone https://github.com/HandBrake/HandBrake.git ~/sources/HandBrake'"
    return 0
  fi
fi

# -----------------------------------------------------------------------------
# Bootstrap build + install. Idempotent: once ghb is installed at the default
# prefix (/usr/local/bin/ghb) we skip the heavy configure+build paso entirely
# -- the `update` script (Step 20) handles roll-forward rebuilds after git pull.
# Default prefix is /usr/local (HandBrake make/configure.py: cfg.prefix_dir).
# -----------------------------------------------------------------------------
if [[ -x /usr/local/bin/ghb ]]; then
  skip "HandBrake already installed (/usr/local/bin/ghb) -- use 'update' to rebuild"
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