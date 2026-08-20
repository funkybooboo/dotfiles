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
  # Debian renames three of these: gst-plugin-pipewire -> gstreamer1.0-pipewire,
  # libpulse -> libpulse0, sof-firmware -> firmware-sof-signed.
  install_apt \
    pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber \
    gstreamer1.0-pipewire libpulse0 pamixer playerctl firmware-sof-signed \
    pipewire-libcamera
  # wiremix is not in apt and publishes no Linux release asset; nix (tier 3)
  # is the cross-distro path and the flake already pins it.
  install_nix .#wiremix
else
  install_pacman \
    pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber \
    gst-plugin-pipewire libpulse pamixer playerctl sof-firmware \
    pipewire-libcamera wiremix
fi
link_file "$DOTFILES_HOME/.config/wiremix/wiremix.toml" "$HOME/.config/wiremix/wiremix.toml"
