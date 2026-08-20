# 000543-caligula.sh -- caligula disk imaging TUI
# Installs: caligula (official extra repo)
# Links:    --
# Enables:  --
# Note: caligula is a user-friendly, lightweight TUI for disk imaging,
#       in the official Arch extra repository.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "caligula"

if is_debian; then
  # Not in apt; take the upstream release binary (tier 2).
  install_gh_release ifd3f/caligula 'x86_64-linux' caligula
else
  install_pacman caligula
fi
