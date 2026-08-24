# 000574-waybar.sh -- waybar (nix flake, patched with upstream PR #5013)
# Nix:     .#waybar  (nixpkgs 0.15.0 + Hyprland Lua-IPC click fix)
# Links:   --
# Enables: --
# Note: Arch's packaged waybar 0.15.0-2 hardcodes the dead `workspace`
#       dispatcher in the hyprland/workspaces module's click handler, which
#       no-ops under Hyprland's Lua config mode (hyprctl dispatch workspace N
#       -> hl.dispatch(workspace N) -> Lua parse error). Upstream fixed this in
#       PR #5013 (auto-detects the Lua IPC protocol, routes via hl.dsp.focus),
#       merged to master 2026-05-04 but no release tag ships it yet and nixpkgs
#       still pins 0.15.0. The flake overlays the PR as a patch on 0.15.0 so
#       the native module's click works and the original workspaces theme is
#       kept. `~/.nix-profile/bin/waybar` shadows `/usr/bin/waybar` because
#       Hyprland's launch PATH (and the systemd user PATH that `uwsm app`
#       uses) has the nix profile first. The pacman waybar stays installed but
#       shadowed -- harmless. Drop this override once nixpkgs waybar ships a
#       release that includes #5013 (expected 0.16.0). Restart waybar after
#       running this for the new binary to take effect.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "waybar"

install_nix .#waybar

ok "waybar"
