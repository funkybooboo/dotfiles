# 000321-icon-theme.sh -- Papirus-Dark icon theme for consistent app icons
# Installs: papirus-icon-theme
# Links:    --
# Enables:  --
# Note:     The icon-theme *name* is set in the already-tracked config files
#           (gtk-3.0/settings.ini, gtk-4.0/settings.ini, xsettingsd.conf,
#           hypr/hyprtoolkit.conf) -- editing those is enough, this migration
#           only owns the package install. Papirus ships Papirus, Papirus-Dark
#           and Papirus-Light; we use Papirus-Dark to match the catppuccin
#           mocha dark aesthetic. It has far better app-icon coverage than
#           Adwaita (which is sparse and falls back to monochrome symbolic
#           icons for non-GNOME apps).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "icon theme"

install_pacman papirus-icon-theme
