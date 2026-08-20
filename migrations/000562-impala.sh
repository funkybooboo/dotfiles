# 000562-impala.sh -- impala (pacman / nix)
# Installs: impala
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. impala is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000530-desktop-apps
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "impala"

if is_debian; then
  # Not in the Ubuntu archive (or only via a third-party PPA), and no
  # upstream Linux release asset -- nixpkgs is the cross-distro source.
  install_nix .#impala
else
  install_pacman impala
fi

ok "impala"
