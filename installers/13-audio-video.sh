# 13-audio-video.sh — audio/video stack

section "Audio/Video"

info "installing audio/video..."
install_pacman \
  pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber \
  mpv obs-studio playerctl pamixer gst-plugin-pipewire \
  libpulse
install_aur wiremix
[[ $DRY_RUN -eq 0 ]] && ok "audio/video" || true