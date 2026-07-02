# 000320-wayland-utilities.sh -- Wayland screenshot/recording/wallpaper/keyboard utils
# Installs (pacman): grim slurp satty swaybg wtype wf-recorder
# Links:    --
# Enables:  --
# Note: grim+slurp+satty power the screenshot script, wf-recorder the
#       screencast script, swaybg the wallpaper service, and wtype the
#       on-screen keyboard -- all wired up in 000310-hyprland.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "Wayland utilities"

if is_debian; then
  install_apt grim slurp swaybg wtype wf-recorder
  # satty (screenshot annotation) is not in apt; install from GitHub release
  install_gh_release gabm/satty x86_64-unknown-linux satty
else
  install_pacman grim slurp satty swaybg wtype wf-recorder
fi

ok "Wayland utilities"
