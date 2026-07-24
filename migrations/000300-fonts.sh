# 000300-fonts.sh — Nerd Fonts + Noto fonts + fontconfig
# Installs: noto-fonts, noto-fonts-cjk, noto-fonts-emoji,
#           ttf-jetbrains-mono-nerd (the one used by ghostty/hyprlock/hyprtoolkit),
#           ttf-nerd-fonts-symbols + ttf-nerd-fonts-symbols-mono (icon/powerline glyphs),
#           fontconfig
# Links:    ~/.config/fontconfig/fonts.conf
# Enables:  —
# Note: Previously installed the entire Nerd Fonts collection (~70 packages,
#       ~8.5 GiB). Trimmed to just JetBrainsMono Nerd Font + the symbols
#       packages (which provide the Powerline/icons glyphs JetBrainsMono
#       uses in terminal/waybar/hyprlock) + Noto base/CJK/emoji. Recovery:
#       ~8.3 GiB. The old 69 other nerd font packages can be removed live with:
#       pacman -Qq | grep nerd | grep -v jetbrains | grep -v symbols | xargs sudo pacman -Rns --noconfirm

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "fonts"

install_pacman \
  noto-fonts noto-fonts-cjk noto-fonts-emoji \
  ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono \
  fontconfig

link_file "$DOTFILES_HOME/.config/fontconfig/fonts.conf" \
  "$HOME/.config/fontconfig/fonts.conf"

# Refresh font cache so newly installed + linked fonts are picked up
if command -v fc-cache &>/dev/null; then
  fc-cache -f >/dev/null 2>&1 || true
  ok "font cache refreshed"
fi
