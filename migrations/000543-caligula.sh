# 000543-caligula.sh - caligula disk imaging TUI
# Installs: caligula (Arch: official extra repo; Debian: GitHub release binary)
# Links:    -
# Enables:  -
# Note: caligula is a user-friendly, lightweight TUI for disk imaging. It is in
#       the Arch extra repo; on Debian/Ubuntu it is not packaged, so we fetch
#       the prebuilt x86_64-linux binary from the upstream GitHub releases into
#       ~/.local/bin.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "caligula"

if is_debian; then
  install_gh_release ifd3f/caligula 'x86_64-linux' caligula
else
  install_pacman caligula
fi
