# 000228-act.sh -- act (pacman / upstream release)
# Installs: act
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. act is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "act"

if is_debian; then
  # Not in the Ubuntu archive; take the upstream release binary (tier 2).
  install_gh_release nektos/act 'Linux_x86_64' act
else
  install_pacman act
fi

ok "act"
