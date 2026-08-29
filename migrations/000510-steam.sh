# 000510-steam.sh -- Steam (pacman)
# Installs: steam
# Links:    --
# Enables:  --
# Note: Steam is installed from the Arch [multilib] repo via pacman. steam
#       hard-Depends On lib32-vulkan-driver + lib32-vulkan-icd-loader (among
#       many lib32-* packages), so pacman pulls the 32-bit Vulkan stack
#       automatically; the 64-bit + 32-bit Vulkan ICD drivers themselves are
#       installed explicitly in 000409-vulkan-drivers (which also enables
#       [multilib] and runs before this migration). steam is NOT installed
#       via nix -- the nix steam package is a buildFHSUserEnv wrapper that
#       ships its own hermetic graphics stack, but we use the native pacman
#       build so steam consumes the host Mesa/Vulkan stack (matching the
#       standard Arch setup and the host GPU drivers from 000409).
#
#       Steam user data (games, Proton, prefixes, config) lives under
#       ~/.local/share/Steam and ~/.steam -- not managed by this migration.
#       For a fresh install, delete those dirs before launching steam.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "steam"

install_pacman steam
