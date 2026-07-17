# 000304-pipewire.sh — PipeWire audio/video server + mixer + wiremix config
# Installs: pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber
#           gst-plugin-pipewire libpulse pamixer playerctl wiremix sof-firmware
# Links:    ~/.config/wiremix/wiremix.toml
# Enables:  —
# Note: sof-firmware provides Sound Open Firmware for Intel audio hardware.
# Note: pipewire-libcamera provides the libcamera SPA plugin
#       (api.libcamera.enum.manager) that wireplumber loads at startup; without
#       it wireplumber warns "PipeWire's libcamera SPA plugin is missing or
#       broken. Some camera types may not be supported."

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "pipewire"

install_pacman \
  pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber \
  gst-plugin-pipewire libpulse pamixer playerctl sof-firmware \
  pipewire-libcamera wiremix
link_file "$DOTFILES_HOME/.config/wiremix/wiremix.toml" "$HOME/.config/wiremix/wiremix.toml"
