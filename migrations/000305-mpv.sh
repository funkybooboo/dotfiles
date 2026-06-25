# 000305-mpv.sh — mpv media player + config + lazymusic player
# Installs: mpv
# Links:    ~/.config/mpv/input.conf,
#           ~/.local/share/applications/lazymusic.desktop
# Enables:  —
# Note: lazymusic.desktop launches the lazymusic mpv-based player, cloned from
#       github.com/funkybooboo/lazymusic.git into ~/sources/lazymusic. The clone
#       happens here (idempotent) so the .desktop Exec path resolves. If the
#       clone is incomplete the .desktop is still linked and will work once the
#       repo is built.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "mpv"

install_pacman mpv
link_file "$DOTFILES_HOME/.config/mpv/input.conf" "$HOME/.config/mpv/input.conf"
link_file "$DOTFILES_HOME/.local/share/applications/lazymusic.desktop" \
  "$HOME/.local/share/applications/lazymusic.desktop"

# Clone lazymusic player into ~/sources (idempotent)
LAZYMUSIC_DIR="$HOME/sources/lazymusic"
if [[ -d "$LAZYMUSIC_DIR/.git" ]]; then
  skip "lazymusic repo (already cloned)"
else
  info "cloning lazymusic → ~/sources/lazymusic..."
  mkdir -p "$HOME/sources"
  if git clone --quiet https://github.com/funkybooboo/lazymusic.git "$LAZYMUSIC_DIR"; then
    ok "lazymusic cloned"
    warn "build lazymusic in ~/sources/lazymusic before launching the .desktop"
    _add_warning "build lazymusic in ~/sources/lazymusic before it will launch"
  else
    warn "failed to clone lazymusic — .desktop will not launch until cloned"
    _add_warning "lazymusic clone failed; run 'git clone https://github.com/funkybooboo/lazymusic.git ~/sources/lazymusic'"
  fi
fi
