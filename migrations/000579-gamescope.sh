# 000579-gamescope.sh -- gamescope (pacman)
# Installs: gamescope
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. gamescope is Valve's
#       micro-compositor (the Steam Deck session compositor), Arch official
#       build (extra/). It runs as a NESTED compositor: on this Hyprland
#       setup it opens as a regular Wayland client window and re-composites
#       the game inside, providing frame limiting, HDR/tonemapping and
#       integer scaling. Launch pattern: gamescope -W 1920 -H 1080 -r 60 -f --
#       <game or steam -tenfoot> (a plain `gamescope -- %command%` in Steam
#       launch options also works). The Vulkan stack (000409) is a runtime
#       dependency and runs earlier. No system service or config file.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "gamescope"

install_pacman gamescope

ok "gamescope"