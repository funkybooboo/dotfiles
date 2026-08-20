# 000212-fastfetch.sh -- fastfetch (pacman / nix)
# Installs: fastfetch
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. fastfetch is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "fastfetch"

if is_debian; then
  # Not in the Ubuntu archive (or only via a third-party PPA), and no
  # upstream Linux release asset -- nixpkgs is the cross-distro source.
  install_nix .#fastfetch
else
  install_pacman fastfetch
fi

ok "fastfetch"
