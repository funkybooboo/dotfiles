# 000601-librewolf-media-codecs.sh -- GStreamer codec plugins for
# browser media (pacman)
# Installs: gst-libav
# Links:    --
# Enables:  --
# Note: Firefox-family browsers on Linux can reach H.264 + AAC
#       decode through the system GStreamer codec set, which is
#       incomplete without gst-libav. Install closes that gap for
#       every Firefox-family browser on the machine.
#       LIBREWOLF CAVEAT (found in the same hunt): LibreWolf upstream
#       builds are compiled WITHOUT the patented codec decoders
#       (H264/HEVC/AAC) -- deliberate upstream policy. No package
#       or pref adds back a decoder the build lacks; about:support
#       -> Media shows H264/AAC "Unsupported" forever. Media
#       playback on this machine belongs to the pacman Firefox;
#       gst-libav still serves it and every other GStreamer
#       consumer. Diagnosed live 2026-11-27 via the jellyfin web
#       client console (VideoCodecNotSupported +
#       manifestIncompatibleCodecsError).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "browser media codecs (gst-libav)"

install_pacman gst-libav

ok "system GStreamer codec set complete (H.264 + AAC reachable)"
