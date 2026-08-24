# 000573-vscode.sh -- Visual Studio Code editor (nix flake)
# Nix:    .#vscode  (local flake, allowUnfree = true, sha256-verified hermetic)
# Links:  --
# Enables: --
# Note: one piece of software = one migration. VS Code ships no upstream
#       Linux release tarball (only the .deb/.rpm from microsoft.com), so the
#       nix flake is the cleanest prebuilt binary path -- hermetic, PR-reviewed,
#       binary-cached. The official Microsoft build is unfree, covered by the
#       flake's allowUnfree = true. If extensions that bundle prebuilt native
#       binaries misbehave under the nix store paths, swap `vscode` for
#       `vscode-fhs` (same editor, FHS-sandbox wrapper) in flake.nix. The
#       MIT-licensed, telemetry-free, open-vsx alternative is `vscodium`.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "vscode"

install_nix .#vscode

ok "vscode"
