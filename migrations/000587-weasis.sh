# 000587-weasis.sh -- Weasis (DICOM medical image viewer, flatpak)
# Installs: io.github.nroduit.Weasis (flathub)
# Links:    --
# Enables:  --
# Note: Opens DICOM imaging discs (DICOMDIR + IMAGES/) that VLC cannot play.
#       Flathub is the author's own (nroduit) official build; AUR is excluded
#       by policy. It is rolled forward by 000301 on every run. The flatpak
#       ships with filesystems=host, so a disc under /run/media/$USER/ is
#       readable without extra overrides. It uses x11 only, so it runs under
#       XWayland. To open a disc: Import DICOM -> CD/DVD, or point it at the
#       DICOMDIR file. Requires the flathub remote (000301-flatpak.sh).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "weasis"

install_flatpak io.github.nroduit.Weasis

ok "weasis"
