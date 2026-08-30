# 000577-heroicgameslauncher.sh -- Heroic Games Launcher (Epic/GOG/Amazon games)
# Flatpak: com.heroicgameslauncher.hgl (Flathub, official upstream build)
# Links:   --
# Enables: --
# Note: One piece of software = one migration. Heroic is a Flatpak GUI that
#       logs into Epic, GOG, and Amazon Prime Gaming accounts and downloads/
#       runs their Windows + Linux game builds -- network + account required
#       at first run. It downloads its own Wine-GE/Proton-GE runners on demand
#       into the sandbox and stores game installs + library metadata under
#       ~/.var/app/com.heroicgameslauncher.hgl/data/heroic (sandboxed, persists
#       across reinstalls). To add a game library, launch Heroic -> Logins ->
#       sign in to the relevant store -> Library -> install a title. Heroic
#       runs Windows titles via its bundled Wine-GE by default; set a per-game
#       Proton/Proton-GE runner in the game's settings if needed. For Steam
#       games use Steam directly (Heroic does not manage Steam libraries);
#       Bottles (000570) is the better pick for standalone Windows apps.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "heroicgameslauncher"

install_flatpak com.heroicgameslauncher.hgl

ok "heroicgameslauncher"
