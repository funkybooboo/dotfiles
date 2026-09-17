# 000305-mpv.sh -- mpv media player + config + lazymusic player
# Installs: mpv
# Links:    ~/.config/mpv/input.conf,
#           ~/.local/share/applications/lazymusic.desktop
# Enables:  --
# Note: lazymusic.desktop launches the lazymusic mpv-based player, whose source
#       lives in the dotfiles git submodule sources/lazymusic (initialized in
#       preflight). The .desktop Exec path points at that submodule checkout.
#       If the submodule is not populated the .desktop is still linked and will
#       work once it is built.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "mpv"

install_pacman mpv
link_file "$DOTFILES_HOME/.config/mpv/input.conf" "$HOME/.config/mpv/input.conf"
link_file "$DOTFILES_HOME/.local/share/applications/lazymusic.desktop" \
  "$HOME/.local/share/applications/lazymusic.desktop"

# lazymusic is loaded from the sources/lazymusic submodule (initialized in
# preflight). Non-fatal, but the .desktop entry will not launch without it.
if source_ready lazymusic; then
  ok "lazymusic source (submodule sources/lazymusic)"
fi
