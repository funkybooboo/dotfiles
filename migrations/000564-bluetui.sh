# 000564-bluetui.sh -- bluetui (pacman / nix)
# Installs: bluetui
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. bluetui is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000530-desktop-apps
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "bluetui"

if is_debian; then
  # Not in the Ubuntu archive (or only via a third-party PPA), and no
  # upstream Linux release asset -- nixpkgs is the cross-distro source.
  install_nix .#bluetui
else
  install_pacman bluetui
fi

ok "bluetui"
