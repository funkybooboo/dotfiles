# 000235-yazi.sh -- Yazi terminal file manager
# Installs: yazi
# Links:    ~/.config/yazi (whole dir, so future keymap.toml/theme.toml ride for free)
# Enables:  --
# Note: link_dir, NOT link_file on yazi.toml. A per-file link_file here would
#   run `ln -s <src> <dest>` where dest ($HOME/.config/yazi/yazi.toml) resolves
#   through the dir symlink to the SAME path as src -- creating a self-
#   referential symlink that destroys the real source file (yazi then fails
#   with "Too many levels of symbolic links"). This was the recurring bug.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "yazi"

install_pacman yazi
link_dir "$DOTFILES_HOME/.config/yazi" "$HOME/.config/yazi"
