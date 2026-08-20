# 000227-lazydocker.sh -- lazydocker (pacman / upstream release)
# Installs: lazydocker
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. lazydocker is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "lazydocker"

if is_debian; then
  # Not in the Ubuntu archive; take the upstream release binary (tier 2).
  install_gh_release jesseduffield/lazydocker 'Linux_x86_64' lazydocker
else
  install_pacman lazydocker
fi

ok "lazydocker"
