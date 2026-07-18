# 000552-handbrake.sh -- HandBrake video transcoder (via pacman)
# Installs: handbrake (from extra/ — official Arch signed package)
# Links:    --
# Enables:  --
# Note: HandBrake is in Arch extra/ (official signed package). Previously
#       built from source via a git submodule, then moved to nixpkgs — but
#       nixpkgs's ffmpeg-full build is currently broken (a patch hunk fails
#       on the pinned nixpkgs revision). pacman's handbrake uses the Arch-
#       maintained ffmpeg which builds fine. Switch to nix .#handbrake when
#       the ffmpeg-full build bug is fixed (run 'nix flake update' and try
#       'nix profile add .#handbrake' again).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "HandBrake"

install_pacman handbrake
