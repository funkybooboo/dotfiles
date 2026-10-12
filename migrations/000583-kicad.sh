# 000583-kicad.sh -- KiCad (pacman)
# Installs: kicad, kicad-library
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. KiCad is the Arch official
#       build (extra/, GPG-signed). kicad-library carries the symbol, footprint
#       and template libraries -- a separate package that kicad does NOT pull
#       in as a dependency, but which the schematic/PCB editors need to be
#       useful, so the two are bundled as one ecosystem (like 000231-texlive).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "kicad"

install_pacman kicad kicad-library

ok "kicad"
