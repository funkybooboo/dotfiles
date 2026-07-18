# 000552-handbrake.sh -- HandBrake video transcoder (via nix)
# Installs: handbrake (via nix — .#handbrake)
# Links:    --
# Enables:  --
# Note: HandBrake is installed from nixpkgs — hermetic, sandboxed build with
#       all dependencies resolved inside the nix store. This replaces the
#       former from-source submodule build (sources/HandBrake). The sources/
#       HandBrake submodule and setup.sh step 10b rebuild harness are now
#       unnecessary for HandBrake (nix handles the build + roll-forward via
#       `nix profile upgrade`).
#       nixpkgs's handbrake build uses upstream's official build system.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "HandBrake"

install_nix .#handbrake
