# 000304-pipewire.sh -- PipeWire audio/video server + mixer + wiremix config
# Installs: pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber
#           gst-plugin-pipewire libpulse pamixer playerctl wiremix sof-firmware
# Links:    ~/.config/wiremix/wiremix.toml
# Enables:  --
# Note: sof-firmware provides Sound Open Firmware for Intel audio hardware.
# Note: pipewire-libcamera provides the libcamera SPA plugin
#       (api.libcamera.enum.manager) that wireplumber loads at startup; without
#       it wireplumber warns "PipeWire's libcamera SPA plugin is missing or
#       broken. Some camera types may not be supported."

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "pipewire"

if is_debian; then
  install_apt \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber \
    gstreamer1.0-pipewire libpulse0 pamixer playerctl \
    firmware-sof-signed libspa-0.2-modules
  _add_warning "wiremix: install via cargo on Debian (cargo install wiremix)"
else
  install_pacman \
    pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber \
    gst-plugin-pipewire libpulse pamixer playerctl sof-firmware \
    pipewire-libcamera
  install_aur wiremix
fi
link_file "$DOTFILES_HOME/.config/wiremix/wiremix.toml" "$HOME/.config/wiremix/wiremix.toml"
