# 000300-fonts.sh -- Nerd Fonts + Noto fonts + fontconfig
# Installs: noto-fonts, noto-fonts-cjk, noto-fonts-emoji, noto-fonts-extra,
#           fontconfig, and the full Nerd Fonts collection
# Links:    ~/.config/fontconfig/fonts.conf
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "fonts"

if is_debian; then
  install_apt fontconfig fonts-noto fonts-noto-cjk fonts-noto-color-emoji fonts-noto-extra
  # Nerd Fonts are not in apt; download a curated subset from ryanoasis/nerd-fonts
  # into ~/.local/share/fonts/NerdFonts/ and run fc-cache.
  _nf_dir="$HOME/.local/share/fonts/NerdFonts"
  mkdir -p "$_nf_dir"
  for _nf in JetBrainsMono CascadiaCode Meslo Hack FiraCode; do
    if find "$_nf_dir" -maxdepth 1 -name "*${_nf}*" 2>/dev/null | grep -q .; then
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
    noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
    ttf-cascadia-mono-nerd ttf-jetbrains-mono-nerd \
    otf-atkinsonhyperlegiblemono-nerd otf-aurulent-nerd otf-codenewroman-nerd \
    otf-comicshanns-nerd otf-commit-mono-nerd otf-droid-nerd otf-firamono-nerd \
    otf-geist-mono-nerd otf-hasklig-nerd otf-hermit-nerd otf-monaspace-nerd \
    otf-opendyslexic-nerd otf-overpass-nerd \
    ttf-0xproto-nerd ttf-3270-nerd ttf-adwaitamono-nerd ttf-agave-nerd \
    ttf-anonymouspro-nerd ttf-arimo-nerd ttf-bigblueterminal-nerd \
    ttf-bitstream-vera-mono-nerd ttf-cascadia-code-nerd ttf-cousine-nerd \
    ttf-d2coding-nerd ttf-daddytime-mono-nerd ttf-dejavu-nerd ttf-envycoder-nerd \
    ttf-fantasque-nerd ttf-firacode-nerd ttf-gohu-nerd ttf-go-nerd ttf-hack-nerd \
    ttf-heavydata-nerd ttf-iawriter-nerd ttf-ibmplex-mono-nerd \
    ttf-inconsolata-go-nerd ttf-inconsolata-lgc-nerd ttf-inconsolata-nerd \
    ttf-intone-nerd ttf-iosevka-nerd ttf-iosevkaterm-nerd \
    ttf-iosevkatermslab-nerd ttf-lekton-nerd ttf-liberation-mono-nerd \
    ttf-lilex-nerd ttf-martian-mono-nerd ttf-meslo-nerd ttf-monofur-nerd \
    ttf-monoid-nerd ttf-mononoki-nerd ttf-mplus-nerd ttf-nerd-fonts-symbols \
    ttf-nerd-fonts-symbols-mono ttf-noto-nerd ttf-profont-nerd ttf-proggyclean-nerd \
    ttf-recursive-nerd ttf-roboto-mono-nerd ttf-sharetech-mono-nerd \
    ttf-sourcecodepro-nerd ttf-space-mono-nerd ttf-terminus-nerd ttf-tinos-nerd \
    ttf-ubuntu-mono-nerd ttf-ubuntu-nerd ttf-victor-mono-nerd ttf-zed-mono-nerd \
    fontconfig
fi

link_file "$DOTFILES_HOME/.config/fontconfig/fonts.conf" \
  "$HOME/.config/fontconfig/fonts.conf"

# Refresh font cache so newly installed + linked fonts are picked up
if command -v fc-cache &>/dev/null; then
  fc-cache -f >/dev/null 2>&1 || true
  ok "font cache refreshed"
fi
