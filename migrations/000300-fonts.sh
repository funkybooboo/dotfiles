# 000300-fonts.sh -- Nerd Fonts + Noto fonts + fontconfig
# Installs: noto-fonts, noto-fonts-cjk, noto-fonts-emoji,
#           ttf-jetbrains-mono-nerd (the one used by ghostty/hyprlock/hyprtoolkit),
#           ttf-nerd-fonts-symbols + ttf-nerd-fonts-symbols-mono (icon/powerline glyphs),
#           fontconfig
# Links:    ~/.config/fontconfig/fonts.conf
# Enables:  --
# Note: Previously installed the entire Nerd Fonts collection (~70 packages,
#       ~8.5 GiB). Trimmed to just JetBrainsMono Nerd Font + the symbols
#       packages (which provide the Powerline/icons glyphs JetBrainsMono
#       uses in terminal/waybar/hyprlock) + Noto base/CJK/emoji. Recovery:
#       ~8.3 GiB. The old 69 other nerd font packages can be removed live with:
#       pacman -Qq | grep nerd | grep -v jetbrains | grep -v symbols | xargs sudo pacman -Rns --noconfirm

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "fonts"

if is_debian; then
  # Noto base/CJK/emoji + fontconfig are all packaged; the Nerd Fonts are not.
  install_apt fontconfig fonts-noto fonts-noto-cjk fonts-noto-color-emoji

  # Nerd Fonts: fetch the same TWO the Arch side installs (JetBrainsMono for
  # text, SymbolsOnly for the Powerline/icon glyphs) from the upstream release
  # into ~/.local/share/fonts/NerdFonts. Deliberately NOT the whole collection
  # -- see the trim note above.
  _nf_dir="$HOME/.local/share/fonts/NerdFonts"
  mkdir -p "$_nf_dir"
  for _nf in JetBrainsMono NerdFontsSymbolsOnly; do
    if find "$_nf_dir" -maxdepth 1 -iname "*${_nf%NerdFontsSymbolsOnly}*" 2>/dev/null | grep -q .; then
      skip "NerdFonts: $_nf (already present)"
      continue
    fi
    info "downloading Nerd Font: $_nf"
    _nf_tmp="$(mktemp)"
    if curl -fsSL \
         "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${_nf}.zip" \
         -o "$_nf_tmp"; then
      if unzip -o -q "$_nf_tmp" '*.ttf' -d "$_nf_dir" 2>/dev/null \
           || unzip -o -q "$_nf_tmp" -d "$_nf_dir" 2>/dev/null; then
        ok "NerdFonts: $_nf"
      else
        warn "failed to extract Nerd Font: $_nf"
        _add_warning "Nerd Font extract failed: $_nf"
      fi
    else
      warn "failed to download Nerd Font: $_nf"
      _add_warning "Nerd Font download failed: $_nf"
    fi
    rm -f "$_nf_tmp"
  done
else
  install_pacman \
    noto-fonts noto-fonts-cjk noto-fonts-emoji \
    ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono \
    fontconfig
fi

link_file "$DOTFILES_HOME/.config/fontconfig/fonts.conf" \
  "$HOME/.config/fontconfig/fonts.conf"

# Refresh font cache so newly installed + linked fonts are picked up
if command -v fc-cache &>/dev/null; then
  fc-cache -f >/dev/null 2>&1 || true
  ok "font cache refreshed"
fi
