# 000231-texlive.sh -- TeX Live (XeLaTeX, fonts, LaTeX extras) for document builds
# Installs: texlive-xetex  texlive-fontsextra  texlive-fontsrecommended  texlive-latexextra
# Links:    --
# Enables:  --
# Note: TeX Live is ONE distribution split across several pacman scheme
#       packages (engine, fonts, latex extras). They are highly related and
#       mutually dependent -- the 'one ecosystem' exception to the one-per-software
#       rule -- so they ship as a single migration. This provides `xelatex`, the
#       build engine the resume repo uses (tectonic, installed by 000108-neovim
#       for the nvim latex plugin, cannot compile the awesome-cv template:
#       tectonic's vendored XeTeX chokes on fontawesome5's virtual-font / utex
#       machinery with a reproducible `free(): invalid pointer`). texlive-xetex
#       pulls texlive-bin + texlive-basic + texlive-latex transitively.
#       texlive-fontsrecommended provides the Latin Modern fonts that
#       awesome-cv uses as its default body font (lmroman10-regular.tfm).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "texlive (xelatex + fonts + latex extras)"

if is_debian; then
  # Debian hyphenates the scheme names: fontsextra -> fonts-extra, etc.
  install_apt \
    texlive-xetex texlive-fonts-extra texlive-fonts-recommended \
    texlive-latex-extra
else
  install_pacman texlive-xetex texlive-fontsextra texlive-fontsrecommended texlive-latexextra
fi

if command -v xelatex >/dev/null 2>&1; then
  ok "xelatex available"
else
  warn "xelatex not on PATH after install (log out/in or rehash shell)"
fi

ok "texlive"