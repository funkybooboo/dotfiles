# 000572-openscad.sh -- OpenSCAD (pacman, programmers solid 3D CAD modeller)
# Installs: openscad
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. OpenSCAD is the Arch official
#       build (extra/, GPG-signed) -- a script-based 3D CAD modeller that pairs
#       with OrcaSlicer (000571) for the design-then-slice 3D-printing workflow.
#       Complements OrcaSlicer: OpenSCAD models geometry in code, OrcaSlicer
#       slices it for the printer. Upstream: https://openscad.org

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "openscad"

install_pacman openscad

ok "openscad"