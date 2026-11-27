# 000601-librewolf-media-codecs.sh -- GStreamer codec plugins for
# browser media (pacman)
# Installs: gst-libav
# Links:    --
# Enables:  --
# Note: Firefox-family browsers on Linux decode H.264 + AAC through
#       GStreamer, not through the ffmpeg CLI. debbie has ffmpeg but
#       lacked gst-libav, so LibreWolf truthfully reported
#       canPlayType(H.264/AAC) = unsupported -- which made every
#       H.264/AAC stream in the homelab media fleet unplayable in
#       the browser (jellyfin: the web client asked for a
#       VideoCodecNotSupported transcode and the player's own HLS
#       engine then rejected the fallback manifest;
#       audiobookshelf: AAC HLS segments undecodable), while MP3 and
#       FLAC services (navidrome) played fine because those codecs
#       are built into the browser itself. Diagnosed live
#       2026-11-27 via the jellyfin web client's console log.
#       gst-plugins-good (containers, common formats) is already
#       installed by the desktop migration set; gst-libav carries
#       the ffmpeg-based codecs the browsers load. After install:
#       fully restart the browser and verify about:support -> Media
#       shows H.264.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "browser media codecs (gst-libav)"

install_pacman gst-libav

ok "librewolf/firefox can decode H.264 + AAC after a full browser restart"
