# 000570-bottles.sh -- Bottles (Wine manager GUI) for running Windows apps
# Flatpak: com.usebottles.bottles (Flathub, official upstream build)
# Links:   --
# Enables: --
# Note: One piece of software = one migration. Bottles is a Flatpak GUI that
#       manages its own Wine runners (caffe/soda/wine-ge) downloaded at first
#       run from Bottles' GitHub release assets -- network required. Bottles
#       stores bottles under ~/.var/app/com.usebottles.bottles/data/bottles
#       (sandboxed, persists across reinstalls). To run a Windows installer,
#       launch Bottles -> Create a bottle (Windows 10) -> "Run executable" and
#       pick the .exe via the file portal (the flatpak is sandboxed; the portal
#       grants one-time access so no flatpak override is needed for normal use).
#       Creality Slicer (.NET/WPF) is known finicky under Wine; if a bottle
#       fails to launch it, fall back to a native slicer (e.g. OrcaSlicer).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "bottles"

install_flatpak com.usebottles.bottles

ok "bottles"