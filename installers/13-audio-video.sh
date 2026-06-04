# 13-audio-video.sh — audio/video stack

section "Audio/Video"

info "installing audio/video..."
run_cmd sudo pacman -S --needed --noconfirm \
  pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber \
  mpv obs-studio playerctl pamixer gst-plugin-pipewire
run_cmd yay -S --needed --noconfirm wiremix
[[ $DRY_RUN -eq 0 ]] && ok "audio/video"