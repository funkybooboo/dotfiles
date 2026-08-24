# 000571-orcaslicer.sh -- OrcaSlicer (native-linux 3D printer slicer)
# Flatpak: com.orcaslicer.OrcaSlicer (Flathub, official upstream build)
# Links:   --
# Enables: --
# Note: One piece of software = one migration. OrcaSlicer is an open-source
#       fork of BambuStudio (CuraEngine lineage) that runs NATIVELY on Linux
#       -- no Wine/Bottles needed -- and supports Creality printers among many
#       others. This replaces the Creality Slicer (.NET/WPF, Windows-only) path
#       that would have required Bottles; the native build gives a much smoother
#       experience and the same slicing engine family. Config/profiles live
#       sandboxed under ~/.var/app/com.orcaslicer.OrcaSlicer/. 3D model files
#       are opened via the xdg file portal (one-time sandbox grant, no flatpak
#       override needed). Upstream: https://github.com/OrcaSlicer/OrcaSlicer

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "orcaslicer"

install_flatpak com.orcaslicer.OrcaSlicer

ok "orcaslicer"