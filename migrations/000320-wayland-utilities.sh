# 000320-wayland-utilities.sh -- Wayland screenshot/recording/wallpaper/keyboard utils
# Installs (pacman): grim slurp satty wtype wf-recorder
# Links:    --
# Enables:  --
# Note: grim+slurp+satty power the screenshot script, wf-recorder the
#       screencast script, and wtype synthetic keystrokes -- all wired up in
#       000310-hyprland. The wallpaper is quickshell's, so swaybg is gone.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "Wayland utilities"

install_pacman grim slurp satty wtype wf-recorder

ok "Wayland utilities"
