# 000580-gamemode.sh -- gamemode (pacman)
# Installs: gamemode lib32-gamemode
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. Feral GameMode: gamemoded
#       auto-requests host optimizations (CPU governor/perf, GPU perf) for
#       the duration of a game. No systemd service -- gamemoded is D-Bus
#       activated on first request, nothing to enable. The gamemoderun
#       wrapper (shipped by this package) requests game mode for ANY child
#       process, including Proton games: Steam launch options
#       "gamescope -W 1920 -H 1080 -f -- gamemoderun %command%" (gamescope
#       000579). lib32-gamemode (multilib, enabled by 000409) adds the
#       32-bit libgamemodeauto for NATIVE 32-bit Linux games that
#       auto-request game mode in-process; Proton titles do not need it
#       (the wrapper covers them). TRAP that motivated this migration:
#       launch options referencing gamemoderun BEFORE this install made
#       gamescope start fullscreen with a failed exec inside -- no game,
#       no window, and the gamescope process ignored SIGTERM (needed
#       kill -9). Keep 000579 before this one in any fresh-machine run.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "gamemode"

install_pacman gamemode lib32-gamemode

ok "gamemode"