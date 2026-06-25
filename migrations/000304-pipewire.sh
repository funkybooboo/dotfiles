# 000304-pipewire.sh — PipeWire audio/video server + mixer + wiremix config
# Installs: pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber
#           gst-plugin-pipewire libpulse pamixer playerctl wiremix sof-firmware
# Links:    ~/.config/wiremix/wiremix.toml
# Enables:  —
# Note: sof-firmware provides Sound Open Firmware for Intel audio hardware.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "pipewire"

install_pacman \
  pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber \
  gst-plugin-pipewire libpulse pamixer playerctl sof-firmware
install_aur wiremix
link_file "$DOTFILES_HOME/.config/wiremix/wiremix.toml" "$HOME/.config/wiremix/wiremix.toml"
