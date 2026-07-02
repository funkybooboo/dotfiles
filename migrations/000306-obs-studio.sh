# 000306-obs-studio.sh -- OBS Studio (screen recording/streaming)
# Installs: obs-studio
# Links:    --
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "obs-studio"

if is_debian; then
  install_apt obs-studio
else
  install_pacman obs-studio
fi
