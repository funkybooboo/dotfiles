# 000320-wayland-utilities.sh — Wayland screenshot/recording/wallpaper/keyboard utils
# Installs (pacman): grim slurp satty swaybg wtype wf-recorder
# Links:    —
# Enables:  —
# Note: grim+slurp+satty power the screenshot script, wf-recorder the
#       screencast script, swaybg the wallpaper service, and wtype the
#       on-screen keyboard — all wired up in 000310-hyprland.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "Wayland utilities"

install_pacman grim slurp satty swaybg wtype wf-recorder

ok "Wayland utilities"
